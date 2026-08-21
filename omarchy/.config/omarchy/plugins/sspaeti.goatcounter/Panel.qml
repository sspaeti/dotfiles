import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

// GoatCounter weekly stats popup: site tabs, a 7-day pageview bar chart, and
// top referrers / locations / systems / languages below. Data is fetched in
// the background and cached on disk, so opening the panel is instant.
Panel {
  id: root
  moduleName: "sspaeti.goatcounter"
  ipcTarget: "sspaeti.goatcounter"
  manageIpc: false

  property var anchorItem: null
  property bool openedFromHotkey: false

  // The bar tracks the widget mounted in its slot — BarWidget.qml — not this
  // nested panel, so everything the bar identifies a panel by must be that
  // widget (popout coordinator, switchPanelFrom).
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  function open() {
    openedFromHotkey = false
    setCenterHoverRevealSuppressed(false)
    captureDeltas()
    root.controller.show()
  }

  function openFromHotkey() {
    openedFromHotkey = true
    captureDeltas()
    root.controller.show()
    // Set after showing: showing hands the popout coordinator over, which
    // closes the previously open panel, and that close clears the flag.
    Qt.callLater(function() {
      if (root.opened) setCenterHoverRevealSuppressed(true)
    })
  }

  function close() {
    setCenterHoverRevealSuppressed(false)
    root.controller.hide()
  }

  function toggle() {
    if (root.opened) root.close()
    else root.openFromHotkey()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  function setCenterHoverRevealSuppressed(value) {
    if (root.bar && "centerHoverRevealSuppressed" in root.bar)
      root.bar.centerHoverRevealSuppressed = value
  }

  readonly property color fg: bar ? bar.foreground : "#e0e0e0"
  readonly property string fontFam: bar ? bar.fontFamily : Style.font.family

  // ---- Stats state, filled by fetch.sh (cached on disk between runs).
  property var data: null
  property string loadError: ""
  property int siteIndex: 0
  property string rangeKey: String(setting("defaultDays", "7"))

  // Optional display names, e.g. {"dedp": "DEDP"} keyed by the derived label.
  readonly property var siteLabels: setting("siteLabels", ({}))
  // Viral-alert thresholds: 0 = off, a number, or a per-site map like
  // {"ssp.sh": 3000}. Checked by fetch.sh on every background refresh.
  readonly property var alertDailyViews: setting("alertDailyViews", 0)
  readonly property var alertHourlyViews: setting("alertHourlyViews", 0)
  // Background fetch cadence in minutes.
  readonly property int refreshMinutes: Math.max(2, Number(setting("refreshMinutes", 15)) || 15)

  readonly property var sites: data && data.sites ? data.sites : []
  readonly property var site: sites.length
    ? sites[Math.min(siteIndex, sites.length - 1)] : null
  readonly property var range: site && site.ranges ? (site.ranges[rangeKey] || null) : null
  readonly property bool ready: site !== null && !site.error && range !== null
  readonly property var days: ready && range.days ? range.days : []
  readonly property real maxDay: Model.maxCount(days)
  readonly property string compactLabel: Model.compactLabel(sites, siteLabels)
  readonly property string activeSiteUrl: site && site.url ? String(site.url) : ""

  // ---- "New since last open": on every open, the difference between the
  //      current counts and the snapshot taken at the previous open is
  //      frozen for display (a brighter cap stacked on each bar), then the
  //      snapshot advances and persists. No close hook needed.
  property var seen: ({})
  property var frozenDeltas: ({})

  function frozenDelta(dayKey) {
    if (!site) return 0
    var perSite = frozenDeltas[site.label]
    if (!perSite) return 0
    var perRange = perSite[rangeKey]
    if (!perRange) return 0
    return Number(perRange[dayKey]) || 0
  }

  readonly property real newViews: {
    var t = 0
    for (var i = 0; i < days.length; i++) t += frozenDelta(days[i].day)
    return t
  }

  function captureDeltas() {
    if (!data || !data.sites || !data.sites.length) return
    var fro = {}
    var snap = {}
    for (var i = 0; i < data.sites.length; i++) {
      var s = data.sites[i]
      if (!s.ranges) continue
      var fPer = {}
      var sPer = {}
      var keys = Object.keys(s.ranges)
      for (var k = 0; k < keys.length; k++) {
        var rg = s.ranges[keys[k]]
        if (!rg || !rg.days) continue
        var prevRange = (seen[s.label] || {})[keys[k]]
        var fm = {}
        var sm = {}
        for (var j = 0; j < rg.days.length; j++) {
          var key = rg.days[j].day
          var c = Number(rg.days[j].count) || 0
          sm[key] = c
          if (!prevRange) fm[key] = 0            // first ever open: no delta
          else if (prevRange[key] === undefined) fm[key] = c  // new day/hour
          else fm[key] = Math.max(0, c - (Number(prevRange[key]) || 0))
        }
        fPer[keys[k]] = fm
        sPer[keys[k]] = sm
      }
      fro[s.label] = fPer
      snap[s.label] = sPer
    }
    root.frozenDeltas = fro
    root.seen = snap
    seenSaveProc.command = ["bash", "-c",
      'dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/goatcounter"; mkdir -p "$dir"; printf %s "$1" > "$dir/seen.json"',
      "_", JSON.stringify(snap)]
    seenSaveProc.running = true
  }

  Process { id: seenSaveProc }

  Process {
    id: seenLoadProc
    command: ["bash", "-c",
      'cat "${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/goatcounter/seen.json" 2>/dev/null']
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var v = JSON.parse(String(text || ""))
          if (v && typeof v === "object") root.seen = v
        } catch (e) {}
      }
    }
  }

  readonly property var topPages: ready ? (range.toppages || []) : []

  // ---- On-demand page search ("/"): the site's full path list (up to 1000
  //      pages, ~150 KB, 6h disk cache) is fetched once; typing matches
  //      locally over ALL pages, and view counts for the visible matches are
  //      fetched per site+range in a small targeted call as you type.
  property bool searchOpen: false
  property var sitePaths: ({})     // label -> [{id, path, title}]
  property var countCache: ({})    // "label|range|path" -> count
  property bool searchLoading: false
  property string searchError: ""

  readonly property var searchMatches: searchOpen && site && sitePaths[site.label]
    ? Model.fuzzyPaths(sitePaths[site.label], searchField.text) : []

  // Same-rank matches re-sort by view count as counts stream in, so the
  // highlighted Enter target is the most-viewed match.
  readonly property var sortedMatches: {
    void countCache
    var arr = searchMatches.slice()
    arr.sort(function(a, b) {
      var ca = Math.max(0, countFor(a.name))
      var cb = Math.max(0, countFor(b.name))
      return a.rank - b.rank || cb - ca || a.name.length - b.name.length
    })
    return arr
  }

  function countFor(path) {
    if (!site) return -1
    var v = countCache[site.label + "|" + rangeKey + "|" + path]
    return v === undefined ? -1 : v
  }

  function scriptPath() {
    return Qt.resolvedUrl("fetch.sh").toString().replace(/^file:\/\//, "")
  }

  function ensurePaths() {
    if (!site || site.error) return
    if (sitePaths[site.label] || pathsProc.running) return
    searchError = ""
    searchLoading = true
    pathsProc.labelAtLaunch = site.label
    pathsProc.command = ["bash", scriptPath(), "--paths", String(site.label)]
    pathsProc.running = true
  }

  function fetchCounts() {
    if (!searchOpen || !site || countsProc.running) return
    var ids = []
    var paths = []
    for (var i = 0; i < searchMatches.length; i++) {
      if (countFor(searchMatches[i].name) === -1) {
        ids.push(searchMatches[i].id)
        paths.push(searchMatches[i].name)
      }
    }
    if (ids.length === 0) return
    countsProc.keyPrefix = site.label + "|" + rangeKey + "|"
    countsProc.requestedPaths = paths
    countsProc.command = ["bash", scriptPath(), "--counts",
      String(site.label), String(rangeKey), ids.join(",")]
    countsProc.running = true
  }

  function openSearch() {
    searchOpen = true
    ensurePaths()
    Qt.callLater(function() { searchField.forceActiveFocus() })
  }

  function closeSearch() {
    searchOpen = false
    searchField.text = ""
    keyCatcher.forceActiveFocus()
  }

  // Enter target: best match that is not hidden as zero-count.
  function searchBestPath() {
    for (var i = 0; i < sortedMatches.length; i++)
      if (countFor(sortedMatches[i].name) !== 0) return sortedMatches[i].name
    return ""
  }

  function searchOpenPage(path) {
    if (root.bar && activeSiteUrl !== "" && path)
      root.bar.run("omarchy-launch-browser " + Util.shellQuote(activeSiteUrl + "/?filter=" + path))
    closeSearch()
  }

  onRangeKeyChanged: if (searchOpen) countsDebounce.restart()
  onSiteIndexChanged: if (searchOpen) { ensurePaths(); countsDebounce.restart() }

  Timer {
    id: countsDebounce
    interval: 300
    onTriggered: root.fetchCounts()
  }

  Process {
    id: pathsProc
    property string labelAtLaunch: ""
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.searchLoading = false
        try {
          var v = JSON.parse(String(text || ""))
          if (v.error) {
            root.searchError = Model.plainText(v.error)
            return
          }
          var m = {}
          for (var k in root.sitePaths) m[k] = root.sitePaths[k]
          m[pathsProc.labelAtLaunch] = v.paths || []
          root.sitePaths = m
          // The user may have switched site while this was in flight.
          if (root.searchOpen && root.site && !root.sitePaths[root.site.label])
            root.ensurePaths()
          countsDebounce.restart()
        } catch (e) {
          root.searchError = "could not load page list"
        }
      }
    }
  }

  Process {
    id: countsProc
    property string keyPrefix: ""
    property var requestedPaths: []
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var v = JSON.parse(String(text || ""))
          var got = {}
          var rows = (v && v.counts) ? v.counts : []
          for (var i = 0; i < rows.length; i++) got[rows[i].name] = Number(rows[i].count) || 0
          var m = {}
          for (var k in root.countCache) m[k] = root.countCache[k]
          // Requested pages absent from the response had no views in range.
          for (var j = 0; j < countsProc.requestedPaths.length; j++) {
            var p = countsProc.requestedPaths[j]
            m[countsProc.keyPrefix + p] = got[p] === undefined ? 0 : got[p]
          }
          root.countCache = m
        } catch (e) {}
        // Pick up matches that appeared while this call was in flight.
        Qt.callLater(root.fetchCounts)
      }
    }
  }
  readonly property var listSpecs: ready ? [
    { title: "Top Referrers", rows: range.toprefs || [] },
    { title: "Locations", rows: range.locations || [] },
    { title: "Systems", rows: range.systems || [] },
    { title: "Languages", rows: range.languages || [] }
  ] : []

  // ---- Geometry.
  readonly property real colW: Style.space(190)
  readonly property real colGap: Style.space(16)
  readonly property real contentW: 4 * colW + 3 * colGap
  readonly property real chartH: Style.space(110)
  readonly property real chartGap: days.length > 7 ? Style.space(3) : Style.space(8)
  readonly property real chartBarW: days.length > 0
    ? (contentW - (days.length - 1) * chartGap) / days.length
    : Style.space(20)
  readonly property real listRowH: Style.space(22)

  property int hoverDay: -1

  function refresh() { runFetch(false) }

  function runFetch(cachedOk) {
    if (fetchProc.running) return
    var script = Qt.resolvedUrl("fetch.sh").toString().replace(/^file:\/\//, "")
    var cmd = ["bash", script]
    if (cachedOk) cmd.push("--cached")
    cmd.push("--alert-daily", JSON.stringify(alertDailyViews || 0),
             "--alert-hourly", JSON.stringify(alertHourlyViews || 0))
    fetchProc.command = cmd
    fetchProc.running = true
  }

  Process {
    id: fetchProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var raw = String(text || "").trim()
        if (raw === "") {
          root.loadError = "fetch.sh produced no output"
          return
        }
        try {
          root.data = JSON.parse(raw)
          root.loadError = root.data && root.data.error ? String(root.data.error) : ""
        } catch (e) {
          root.loadError = "Could not parse stats JSON"
        }
      }
    }
  }

  // Background refresh keeps the cache warm so a click on the bar is instant.
  Timer {
    interval: root.refreshMinutes * 60 * 1000
    running: true
    repeat: true
    onTriggered: root.runFetch(false)
  }

  Component.onCompleted: {
    seenLoadProc.running = true
    root.runFetch(true)
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    // contentWidth is the card's outer width: unlike fittedContentHeight,
    // fittedContentWidth does not add the padding/border inset, so add it
    // here or the last column gets clipped.
    contentWidth: panel.fittedContentWidth(root.contentW + panel.verticalContentInset)
    contentHeight: panel.fittedContentHeight(mainCol.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      // While the search box has focus, hand every key to it.
      blocked: searchField.activeFocus
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      // p: next site tab · 1/2/3: range 1d/7d/30d · o: open dashboard ·
      // /: fuzzy page search.
      onTextKey: function(t) {
        if (t === "/") {
          root.openSearch()
        } else if (t === "p" && root.sites.length > 0) {
          root.siteIndex = (root.siteIndex + 1) % root.sites.length
        } else if (t === "1" || t === "2" || t === "3") {
          root.hoverDay = -1
          root.rangeKey = t === "1" ? "1" : (t === "2" ? "7" : "30")
        } else if (t === "o" && root.activeSiteUrl !== "" && root.bar) {
          root.bar.run("omarchy-launch-browser " + Util.shellQuote(root.activeSiteUrl))
          root.close()
        }
      }

      Column {
        id: mainCol
        width: parent.width
        spacing: Style.space(14)

        // ---- Header: site tabs, week total, updated-at.
        Item {
          width: parent.width
          height: tabsRow.implicitHeight

          Row {
            id: tabsRow
            spacing: Style.space(6)

            Repeater {
              model: root.sites

              Rectangle {
                required property var modelData
                required property int index
                readonly property bool active: index === root.siteIndex
                width: tabText.implicitWidth + Style.space(20)
                height: tabText.implicitHeight + Style.space(10)
                radius: height / 2
                color: active ? Qt.alpha(Color.accent, 0.30)
                     : tabMouse.containsMouse ? Qt.alpha(root.fg, 0.12)
                     : Qt.alpha(root.fg, 0.05)

                Text {
                  id: tabText
                  anchors.centerIn: parent
                  text: Model.displayLabel(parent.modelData, root.siteLabels)
                  textFormat: Text.PlainText
                  color: parent.active ? root.fg : Qt.darker(root.fg, 1.3)
                  font.family: root.fontFam
                  font.pixelSize: Style.font.bodySmall
                  font.bold: parent.active
                }

                MouseArea {
                  id: tabMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  onClicked: root.siteIndex = parent.index
                }
              }
            }

            // Separator between site tabs and the range toggle.
            Rectangle {
              visible: root.sites.length > 1
              width: 1
              height: Style.space(16)
              anchors.verticalCenter: parent.verticalCenter
              color: Qt.alpha(root.fg, 0.15)
            }

            Repeater {
              model: [{ key: "1", label: "1d" }, { key: "7", label: "7d" }, { key: "30", label: "30d" }]

              Rectangle {
                required property var modelData
                readonly property bool active: modelData.key === root.rangeKey
                width: rangeText.implicitWidth + Style.space(16)
                height: rangeText.implicitHeight + Style.space(10)
                radius: height / 2
                color: active ? Qt.alpha(Color.accent, 0.30)
                     : rangeMouse.containsMouse ? Qt.alpha(root.fg, 0.12)
                     : Qt.alpha(root.fg, 0.05)

                Text {
                  id: rangeText
                  anchors.centerIn: parent
                  text: parent.modelData.label
                  color: parent.active ? root.fg : Qt.darker(root.fg, 1.3)
                  font.family: root.fontFam
                  font.pixelSize: Style.font.bodySmall
                  font.bold: parent.active
                }

                MouseArea {
                  id: rangeMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  onClicked: {
                    root.hoverDay = -1
                    root.rangeKey = parent.modelData.key
                  }
                }
              }
            }
          }

          Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(8)

            Column {
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(1)

              Text {
                anchors.right: parent.right
                text: root.ready
                  ? Model.fmtCount(root.range.total) + " views · "
                    + (root.rangeKey === "1" ? "today" : root.rangeKey + " days")
                  : ""
                color: root.fg
                font.family: root.fontFam
                font.pixelSize: Style.font.body
                font.bold: true
              }
              Text {
                anchors.right: parent.right
                visible: root.newViews > 0
                text: "+" + Model.fmtCount(root.newViews) + " since last open"
                color: Color.accent
                font.family: root.fontFam
                font.pixelSize: Style.font.caption
                font.bold: true
              }
              Text {
                anchors.right: parent.right
                text: root.data && root.data.fetched
                  ? "updated " + Model.updatedLabel(root.data.fetched) : ""
                color: Qt.darker(root.fg, 1.5)
                font.family: root.fontFam
                font.pixelSize: Style.font.caption
              }
            }

            // Opens the active site's GoatCounter dashboard in the browser.
            Rectangle {
              visible: root.activeSiteUrl !== ""
              anchors.verticalCenter: parent.verticalCenter
              width: Style.space(26)
              height: Style.space(26)
              radius: Style.space(6)
              color: linkMouse.containsMouse ? Qt.alpha(Color.accent, 0.25)
                   : Qt.alpha(root.fg, 0.06)

              Text {
                anchors.centerIn: parent
                text: "󰏌"
                color: linkMouse.containsMouse ? root.fg : Qt.darker(root.fg, 1.3)
                font.family: root.fontFam
                font.pixelSize: Style.font.bodySmall
              }

              MouseArea {
                id: linkMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                  if (root.bar && root.activeSiteUrl !== "")
                    root.bar.run("omarchy-launch-browser " + Util.shellQuote(root.activeSiteUrl))
                }
              }
            }
          }
        }

        // ---- "/" page search: text box + fuzzy results for current range.
        Column {
          visible: root.searchOpen
          width: parent.width
          spacing: Style.space(4)

          Rectangle {
            width: parent.width
            height: searchField.implicitHeight + Style.space(14)
            radius: Style.space(6)
            color: Qt.alpha(root.fg, 0.06)
            border.width: 1
            border.color: searchField.activeFocus
              ? Qt.alpha(Color.accent, 0.6) : Qt.alpha(root.fg, 0.15)

            TextInput {
              id: searchField
              anchors.fill: parent
              anchors.leftMargin: Style.space(10)
              anchors.rightMargin: Style.space(10)
              verticalAlignment: TextInput.AlignVCenter
              color: root.fg
              selectionColor: Qt.alpha(Color.accent, 0.4)
              font.family: root.fontFam
              font.pixelSize: Style.font.bodySmall
              clip: true
              onTextChanged: countsDebounce.restart()
              Keys.onEscapePressed: root.closeSearch()
              Keys.onReturnPressed: root.searchOpenPage(root.searchBestPath())
              Keys.onEnterPressed: root.searchOpenPage(root.searchBestPath())

              Text {
                visible: searchField.text === ""
                anchors.verticalCenter: parent.verticalCenter
                text: "search pages…   Enter: open best match in dashboard · Esc: close"
                color: Qt.darker(root.fg, 1.6)
                font.family: root.fontFam
                font.pixelSize: Style.font.bodySmall
              }
            }
          }

          Text {
            visible: root.searchLoading || root.searchError !== ""
            text: root.searchError !== "" ? root.searchError : "loading page list…"
            color: Qt.darker(root.fg, 1.5)
            font.family: root.fontFam
            font.pixelSize: Style.font.caption
            font.italic: true
          }

          Repeater {
            model: root.sortedMatches

            Item {
              id: resRow
              required property var modelData
              required property int index
              width: root.contentW
              // Pages with no views in the selected range are hidden once
              // their count comes back as zero.
              readonly property bool dead: root.countFor(modelData.name) === 0
              visible: !dead
              height: dead ? 0 : root.listRowH

              Rectangle {
                anchors.fill: parent
                radius: Style.space(3)
                color: resRow.index === 0
                  ? Qt.alpha(Color.accent, 0.18) : Qt.alpha(root.fg, 0.04)
              }

              Text {
                anchors.left: parent.left
                anchors.right: resCount.left
                anchors.leftMargin: Style.space(6)
                anchors.rightMargin: Style.space(6)
                anchors.verticalCenter: parent.verticalCenter
                text: Model.plainText(resRow.modelData.name)
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: root.fg
                font.family: root.fontFam
                font.pixelSize: Style.font.caption
              }

              Text {
                id: resCount
                anchors.right: parent.right
                anchors.rightMargin: Style.space(4)
                anchors.verticalCenter: parent.verticalCenter
                text: {
                  var c = root.countFor(resRow.modelData.name)
                  return c < 0 ? "…" : Model.fmtCount(c)
                }
                color: Qt.darker(root.fg, 1.3)
                font.family: root.fontFam
                font.pixelSize: Style.font.caption
                font.bold: resRow.index === 0
              }

              MouseArea {
                anchors.fill: parent
                onClicked: root.searchOpenPage(resRow.modelData.name)
              }
            }
          }

          Text {
            visible: !root.searchLoading && root.searchError === ""
              && searchField.text !== "" && root.searchMatches.length === 0
            text: "no matching page (first 1000 pages searched)"
            color: Qt.darker(root.fg, 1.5)
            font.family: root.fontFam
            font.pixelSize: Style.font.caption
            font.italic: true
          }
        }

        // ---- Status: loading, missing credentials, or per-site API errors.
        Text {
          visible: !root.ready
          width: parent.width
          wrapMode: Text.WordWrap
          text: root.data === null
            ? "Loading stats…"
            : (root.site && root.site.error
                ? Model.plainText(root.site.label) + ": " + Model.plainText(root.site.error)
                : (root.loadError !== ""
                    ? root.loadError + "\nAdd GOATCOUNTER_URL / GOATCOUNTER_TOKEN to your secrets file."
                    : "No data yet."))
          color: Qt.darker(root.fg, 1.3)
          font.family: root.fontFam
          font.pixelSize: Style.font.bodySmall
          font.italic: true
        }

        // ---- 7-day bar chart: count above, bar, weekday below.
        Row {
          visible: root.ready
          spacing: root.chartGap

          Repeater {
            model: root.days

            Column {
              id: dayCol
              required property var modelData
              required property int index
              readonly property real count: Number(modelData.count) || 0
              readonly property bool hot: index === root.hoverDay
              readonly property real delta: root.frozenDelta(modelData.day)
              readonly property real barH: root.maxDay > 0
                ? Math.max(Style.space(2), root.chartH * count / root.maxDay)
                : Style.space(2)
              readonly property real deltaH: count > 0 && delta > 0
                ? Math.max(Style.space(2), barH * Math.min(1, delta / count))
                : 0
              // In the dense views labels only fit on hover (counts) and on
              // ticks aligned to the last bar: every 3 hours today, weekly
              // over 30 days.
              readonly property bool compact: root.days.length > 7
              readonly property int tickStep: root.rangeKey === "1" ? 3 : 7
              readonly property bool axisTick: !compact || (root.days.length - 1 - index) % tickStep === 0
              width: root.chartBarW
              spacing: Style.space(4)

              Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: (!dayCol.compact || dayCol.hot) ? Model.fmtCount(dayCol.count) : " "
                color: dayCol.hot ? Color.accent : Qt.darker(root.fg, 1.4)
                font.family: root.fontFam
                font.pixelSize: Style.font.caption
                font.bold: dayCol.hot
              }

              Item {
                width: parent.width
                height: root.chartH

                Rectangle {
                  anchors.bottom: parent.bottom
                  anchors.horizontalCenter: parent.horizontalCenter
                  width: parent.width
                  height: dayCol.barH
                  radius: Style.space(3)
                  color: Qt.alpha(Color.accent, dayCol.hot ? 0.8 : 0.45)
                }

                // Views that arrived since the panel was last open, stacked
                // as a brighter cap on top of the bar.
                Rectangle {
                  visible: dayCol.deltaH > 0
                  anchors.bottom: parent.bottom
                  anchors.bottomMargin: dayCol.barH - dayCol.deltaH
                  anchors.horizontalCenter: parent.horizontalCenter
                  width: parent.width
                  height: dayCol.deltaH
                  radius: Style.space(3)
                  color: Color.accent
                }

                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  acceptedButtons: Qt.NoButton
                  onEntered: root.hoverDay = dayCol.index
                  onExited: if (root.hoverDay === dayCol.index) root.hoverDay = -1
                }
              }

              Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: dayCol.axisTick ? Model.dayLabel(dayCol.modelData.day) : " "
                color: Qt.darker(root.fg, 1.4)
                font.family: root.fontFam
                font.pixelSize: Style.font.caption
              }
            }
          }
        }

        // ---- Top pages, GoatCounter-style full-width rows.
        Column {
          visible: root.ready && root.topPages.length > 0
          width: parent.width
          spacing: Style.space(4)

          Text {
            text: "Top Pages"
            color: root.fg
            font.family: root.fontFam
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }

          Repeater {
            model: root.topPages

            Item {
              id: pageRow
              required property var modelData
              readonly property real maxRow: Model.maxCount(root.topPages)
              width: root.contentW
              height: root.listRowH

              Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: pageRow.maxRow > 0
                  ? Math.max(Style.space(3), root.contentW * (Number(pageRow.modelData.count) || 0) / pageRow.maxRow)
                  : 0
                height: parent.height
                radius: Style.space(3)
                color: Qt.alpha(Color.accent, 0.16)
              }

              Text {
                anchors.left: parent.left
                anchors.right: pageCount.left
                anchors.leftMargin: Style.space(6)
                anchors.rightMargin: Style.space(6)
                anchors.verticalCenter: parent.verticalCenter
                text: Model.plainText(pageRow.modelData.name)
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: root.fg
                font.family: root.fontFam
                font.pixelSize: Style.font.caption
              }

              Text {
                id: pageCount
                anchors.right: parent.right
                anchors.rightMargin: Style.space(4)
                anchors.verticalCenter: parent.verticalCenter
                text: Model.fmtCount(pageRow.modelData.count)
                color: Qt.darker(root.fg, 1.4)
                font.family: root.fontFam
                font.pixelSize: Style.font.caption
              }
            }
          }
        }

        // ---- Top lists: referrers, locations, systems, languages.
        Row {
          visible: root.ready
          spacing: root.colGap

          Repeater {
            model: root.listSpecs

            Column {
              id: listCol
              required property var modelData
              readonly property real maxRow: Model.maxCount(modelData.rows)
              width: root.colW
              spacing: Style.space(4)

              Text {
                text: listCol.modelData.title
                color: root.fg
                font.family: root.fontFam
                font.pixelSize: Style.font.bodySmall
                font.bold: true
              }

              Repeater {
                model: listCol.modelData.rows

                Item {
                  id: listRow
                  required property var modelData
                  width: root.colW
                  height: root.listRowH

                  // Proportional background bar behind the label.
                  Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: listCol.maxRow > 0
                      ? Math.max(Style.space(3), root.colW * (Number(listRow.modelData.count) || 0) / listCol.maxRow)
                      : 0
                    height: parent.height
                    radius: Style.space(3)
                    color: Qt.alpha(Color.accent, 0.16)
                  }

                  Text {
                    anchors.left: parent.left
                    anchors.right: countText.left
                    anchors.leftMargin: Style.space(6)
                    anchors.rightMargin: Style.space(6)
                    anchors.verticalCenter: parent.verticalCenter
                    text: Model.plainText(listRow.modelData.name)
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    color: root.fg
                    font.family: root.fontFam
                    font.pixelSize: Style.font.caption
                  }

                  Text {
                    id: countText
                    anchors.right: parent.right
                    anchors.rightMargin: Style.space(4)
                    anchors.verticalCenter: parent.verticalCenter
                    text: Model.fmtCount(listRow.modelData.count)
                    color: Qt.darker(root.fg, 1.4)
                    font.family: root.fontFam
                    font.pixelSize: Style.font.caption
                  }
                }
              }

              Text {
                visible: (listCol.modelData.rows || []).length === 0
                text: "no data"
                color: Qt.darker(root.fg, 1.6)
                font.family: root.fontFam
                font.pixelSize: Style.font.caption
                font.italic: true
              }
            }
          }
        }
      }
    }
  }
}
