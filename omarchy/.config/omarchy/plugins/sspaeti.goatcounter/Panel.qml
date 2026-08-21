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
    root.controller.show()
  }

  function openFromHotkey() {
    openedFromHotkey = true
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

  readonly property var sites: data && data.sites ? data.sites : []
  readonly property var site: sites.length
    ? sites[Math.min(siteIndex, sites.length - 1)] : null
  readonly property var range: site && site.ranges ? (site.ranges[rangeKey] || null) : null
  readonly property bool ready: site !== null && !site.error && range !== null
  readonly property var days: ready && range.days ? range.days : []
  readonly property real maxDay: Model.maxCount(days)
  readonly property string compactLabel: Model.compactLabel(sites, siteLabels)
  readonly property string activeSiteUrl: site && site.url ? String(site.url) : ""

  readonly property var topPages: ready ? (range.toppages || []) : []
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
    interval: 15 * 60 * 1000
    running: true
    repeat: true
    onTriggered: root.runFetch(false)
  }

  Component.onCompleted: root.runFetch(true)

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
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

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
              model: [{ key: "7", label: "7d" }, { key: "30", label: "30d" }]

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

          Column {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(1)

            Text {
              anchors.right: parent.right
              text: root.ready
                ? Model.fmtCount(root.range.total) + " views · " + root.rangeKey + " days" : ""
              color: root.fg
              font.family: root.fontFam
              font.pixelSize: Style.font.body
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
              // In the 30-day view labels only fit on hover (counts) and on
              // weekly ticks aligned to today (dates).
              readonly property bool compact: root.days.length > 7
              readonly property bool axisTick: !compact || (root.days.length - 1 - index) % 7 === 0
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
                  height: root.maxDay > 0
                    ? Math.max(Style.space(2), root.chartH * dayCol.count / root.maxDay)
                    : Style.space(2)
                  radius: Style.space(3)
                  color: Qt.alpha(Color.accent, dayCol.hot ? 0.95 : 0.65)
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
