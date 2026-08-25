import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

// neomd mail popup: HEY-style folder tabs (Inbox / ToScreen / Feed /
// PaperTrail) and an in-panel reader — strictly read-only. Bodies are
// fetched with BODY.PEEK, so glancing at a mail here never marks it read.
// Data is polled in the background and cached on disk, so opening the panel
// is instant — but nothing on the bar ever shows a count.
Panel {
  id: root
  moduleName: "io.github.sspaeti.neomd"
  ipcTarget: "io.github.sspaeti.neomd"
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

  // ---- Settings.
  readonly property var tabNames: setting("folders", ["Inbox", "ToScreen", "Feed", "PaperTrail"])
  readonly property string defaultTab: String(setting("defaultTab", "ToScreen"))
  readonly property int limit: Math.max(1, Number(setting("limit", 15)) || 15)
  readonly property int refreshMinutes: Math.max(2, Number(setting("refreshMinutes", 5)) || 5)
  readonly property string jumpCommand: String(setting("jumpCommand",
    Quickshell.env("HOME") + "/.config/hypr/sspaeti/jump-to-email-tmux.sh"))
  // Alternate neomd config.toml (e.g. a demo account for screen recordings).
  // Empty = neomd's default config. fetch.sh keeps a separate cache per
  // config, so switching never mixes demo and real mail.
  readonly property string configPath: String(setting("configPath", ""))

  function baseCmd() {
    var cmd = ["bash", scriptPath()]
    if (configPath !== "") cmd.push("--config", configPath)
    return cmd
  }

  // ---- Mail state, filled by fetch.sh (cached on disk between runs).
  property var data: null
  property string loadError: ""
  property int tabIndex: Math.max(0, tabNames.indexOf(defaultTab))
  property int selIndex: 0

  readonly property string tabName: tabNames[Math.min(tabIndex, tabNames.length - 1)] || ""
  readonly property var folder: Model.folderByName(data, tabName)
  readonly property var emails: folder && folder.emails ? folder.emails : []
  readonly property bool ready: data !== null && data.ok === true
  readonly property bool stale: ready && data.stale === true
  readonly property var selected: emails.length > 0
    ? emails[Math.min(selIndex, emails.length - 1)] : null

  onTabIndexChanged: {
    selIndex = 0
    closeReading()
  }
  onDataChanged: selIndex = Math.min(selIndex, Math.max(0, emails.length - 1))

  function scriptPath() {
    return Qt.resolvedUrl("fetch.sh").toString().replace(/^file:\/\//, "")
  }

  function refresh() { runFetch(false) }

  function runFetch(cachedOk) {
    if (fetchProc.running) return
    var cmd = baseCmd()
    if (cachedOk) cmd.push("--cached")
    cmd.push("--folders", tabNames.join(","), "--limit", String(limit))
    fetchProc.command = cmd
    fetchProc.running = true
  }

  function jumpToNeomd() {
    if (root.bar && jumpCommand !== "") {
      root.bar.run(jumpCommand)
      root.close()
    }
  }

  function switchTab(delta) {
    root.tabIndex = (root.tabIndex + delta + root.tabNames.length) % root.tabNames.length
  }

  // ---- In-panel reader: l/Enter opens the selected mail's body (BODY.PEEK,
  //      never marks it read), h/Esc goes back. Bodies are immutable, so
  //      they are cached per folder|uid for the panel's lifetime.
  property var reading: null       // header of the mail being read
  property string bodyText: ""
  property string bodyError: ""
  property var bodyCache: ({})     // "folder|uid" -> body text

  function openSelected() {
    if (!root.selected) return
    var mail = root.selected
    reading = mail
    bodyError = ""
    var key = root.configPath + "|" + root.tabName + "|" + mail.uid
    if (bodyCache[key] !== undefined) {
      bodyText = bodyCache[key]
      return
    }
    bodyText = ""
    if (readProc.running) return
    readProc.cacheKey = key
    var cmd = baseCmd()
    cmd.push("--read", root.tabName, String(mail.uid))
    readProc.command = cmd
    readProc.running = true
  }

  function closeReading() {
    reading = null
    bodyText = ""
    bodyError = ""
  }

  Process {
    id: readProc
    property string cacheKey: ""
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var v = JSON.parse(String(text || ""))
          if (v.ok !== true) {
            root.bodyError = Model.plainText(v.error || "could not load body")
            return
          }
          var body = Model.sanitizeBody(v.body)
          if (v.truncated) body += "\n\n… (truncated — open neomd for the rest)"
          var m = {}
          for (var k in root.bodyCache) m[k] = root.bodyCache[k]
          m[readProc.cacheKey] = body
          root.bodyCache = m
          if (root.reading && root.configPath + "|" + root.tabName + "|" + root.reading.uid === readProc.cacheKey)
            root.bodyText = body
        } catch (e) {
          root.bodyError = "could not parse body JSON"
        }
      }
    }
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
          var v = JSON.parse(raw)
          root.data = v
          root.loadError = v && v.ok === false ? Model.plainText(v.error || "unknown error") : ""
        } catch (e) {
          root.loadError = "Could not parse mail JSON"
        }
      }
    }
  }

  // Background refresh keeps the cache warm so a click on the bar is
  // instant — the pill itself never changes, whatever arrives.
  Timer {
    interval: root.refreshMinutes * 60 * 1000
    running: true
    repeat: true
    onTriggered: root.runFetch(false)
  }

  Component.onCompleted: root.runFetch(true)

  // ---- Geometry.
  readonly property real contentW: Style.space(560)
  readonly property real rowH: Style.space(30)
  readonly property real readerH: Style.space(480)

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(root.contentW + panel.verticalContentInset)
    contentHeight: panel.fittedContentHeight(mainCol.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      // PanelKeyCatcher owns j/k/h/l and arrows: they arrive here as
      // moveRequested, NOT as textKey.
      //   list view:    j/k move · l/Enter open mail · H/L or 1-4 tabs
      //   reading view: j/k scroll · h back
      onMoveRequested: function(dx, dy) {
        if (root.reading) {
          if (dx < 0) { root.closeReading(); return }
          if (dy !== 0) bodyFlick.scrollBy(dy)
          return
        }
        if (dy !== 0 && root.emails.length > 0) {
          root.selIndex = Math.max(0, Math.min(root.selIndex + dy, root.emails.length - 1))
        } else if (dx > 0) {
          root.openSelected()
        }
      }
      onActivateRequested: if (!root.reading) root.openSelected()
      // Esc peels the reader off first, then closes the panel.
      onCloseRequested: {
        if (root.reading) root.closeReading()
        else root.close()
      }
      onTabRequested: function(direction) { root.switchPanel(direction) }
      // H/L: prev/next tab · 1-4: tab · o: open neomd · r/R: refresh.
      onTextKey: function(t) {
        if (t === "H") {
          root.switchTab(-1)
        } else if (t === "L") {
          root.switchTab(1)
        } else if (t >= "1" && t <= String(root.tabNames.length)) {
          root.tabIndex = Number(t) - 1
        } else if (t === "o") {
          root.jumpToNeomd()
        } else if (t === "r" || t === "R") {
          root.refresh()
        }
      }

      Column {
        id: mainCol
        width: parent.width
        spacing: Style.space(10)

        // ---- Header: folder tabs left, account + updated + jump right.
        Item {
          width: parent.width
          height: tabsRow.implicitHeight

          Row {
            id: tabsRow
            spacing: Style.space(6)

            Repeater {
              model: root.tabNames

              Rectangle {
                required property var modelData
                required property int index
                readonly property bool active: index === root.tabIndex
                readonly property int unread: Model.unreadCount(Model.folderByName(root.data, modelData))
                width: tabText.implicitWidth + Style.space(20)
                height: tabText.implicitHeight + Style.space(10)
                radius: height / 2
                color: active ? Qt.alpha(Color.accent, 0.30)
                     : tabMouse.containsMouse ? Qt.alpha(root.fg, 0.12)
                     : Qt.alpha(root.fg, 0.05)

                Text {
                  id: tabText
                  anchors.centerIn: parent
                  // Unread count lives here, inside the panel — never on the bar.
                  text: parent.modelData + (parent.unread > 0 ? " " + parent.unread : "")
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
                  onClicked: root.tabIndex = parent.index
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
                text: root.ready ? Model.plainText(root.data.account) : ""
                color: root.fg
                font.family: root.fontFam
                font.pixelSize: Style.font.caption
                font.bold: true
              }
              Text {
                anchors.right: parent.right
                text: {
                  if (fetchProc.running) return "refreshing…"
                  if (root.ready && root.data.fetched)
                    return (root.stale ? "stale · " : "updated ")
                      + Model.updatedLabel(root.data.fetched)
                  return ""
                }
                color: Qt.darker(root.fg, 1.5)
                font.family: root.fontFam
                font.pixelSize: Style.font.caption
              }
            }

            // Opens neomd itself (tmux jump), same as pressing o.
            Rectangle {
              anchors.verticalCenter: parent.verticalCenter
              width: Style.space(26)
              height: Style.space(26)
              radius: Style.space(6)
              color: jumpMouse.containsMouse ? Qt.alpha(Color.accent, 0.25)
                   : Qt.alpha(root.fg, 0.06)

              Text {
                anchors.centerIn: parent
                text: "󰆍"
                color: jumpMouse.containsMouse ? root.fg : Qt.darker(root.fg, 1.3)
                font.family: root.fontFam
                font.pixelSize: Style.font.bodySmall
              }

              MouseArea {
                id: jumpMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.jumpToNeomd()
              }
            }
          }
        }

        // ---- Status: loading or error.
        Text {
          visible: !root.ready
          width: parent.width
          wrapMode: Text.WordWrap
          text: root.data === null
            ? "Loading mail…"
            : (root.loadError !== "" ? root.loadError : "No data yet.")
          color: Qt.darker(root.fg, 1.3)
          font.family: root.fontFam
          font.pixelSize: Style.font.bodySmall
          font.italic: true
        }

        // ---- List view: dot · sender · subject · time.
        Column {
          visible: root.reading === null
          width: parent.width
          spacing: Style.space(2)

          Repeater {
            model: root.reading === null ? root.emails : []

            Item {
              id: mailRow
              required property var modelData
              required property int index
              readonly property bool sel: index === root.selIndex
              width: root.contentW
              height: root.rowH

              Rectangle {
                anchors.fill: parent
                radius: Style.space(4)
                color: mailRow.sel ? Qt.alpha(Color.accent, 0.16)
                     : rowMouse.containsMouse ? Qt.alpha(root.fg, 0.06)
                     : "transparent"
              }

              MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                  root.selIndex = mailRow.index
                  root.openSelected()
                }
              }

              Rectangle {
                id: dot
                anchors.left: parent.left
                anchors.leftMargin: Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                width: Style.space(6)
                height: width
                radius: width / 2
                color: mailRow.modelData.unread ? Color.accent : Qt.alpha(root.fg, 0.15)
              }

              Text {
                id: senderText
                anchors.left: dot.right
                anchors.leftMargin: Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                width: Style.space(130)
                text: Model.plainText(Model.senderName(mailRow.modelData.from))
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: mailRow.modelData.unread ? root.fg : Qt.darker(root.fg, 1.3)
                font.family: root.fontFam
                font.pixelSize: Style.font.caption
                font.bold: mailRow.modelData.unread === true
              }

              Text {
                anchors.left: senderText.right
                anchors.leftMargin: Style.space(8)
                anchors.right: timeText.left
                anchors.rightMargin: Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                text: Model.plainText(mailRow.modelData.subject)
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: mailRow.modelData.unread ? root.fg : Qt.darker(root.fg, 1.25)
                font.family: root.fontFam
                font.pixelSize: Style.font.caption
              }

              Text {
                id: timeText
                anchors.right: parent.right
                anchors.rightMargin: Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                text: Model.relTime(mailRow.modelData.date)
                color: Qt.darker(root.fg, 1.5)
                font.family: root.fontFam
                font.pixelSize: Style.font.caption
              }
            }
          }

          Text {
            visible: root.ready && root.emails.length === 0
            text: root.tabName === "ToScreen" ? "screener queue empty 🎉" : "nothing here"
            color: Qt.darker(root.fg, 1.5)
            font.family: root.fontFam
            font.pixelSize: Style.font.caption
            font.italic: true
          }
        }

        // ---- Reading view: header + scrollable markdown body (peek-only).
        Column {
          visible: root.reading !== null
          width: parent.width
          spacing: Style.space(8)

          Column {
            width: parent.width
            spacing: Style.space(2)

            Text {
              width: parent.width
              text: root.reading ? Model.plainText(root.reading.subject) : ""
              textFormat: Text.PlainText
              wrapMode: Text.WordWrap
              color: root.fg
              font.family: root.fontFam
              font.pixelSize: Style.font.body
              font.bold: true
            }
            Text {
              width: parent.width
              text: root.reading
                ? Model.plainText(root.reading.from) + " · " + Model.relTime(root.reading.date)
                : ""
              textFormat: Text.PlainText
              elide: Text.ElideRight
              color: Qt.darker(root.fg, 1.4)
              font.family: root.fontFam
              font.pixelSize: Style.font.caption
            }
          }

          Rectangle {
            width: parent.width
            height: 1
            color: Qt.alpha(root.fg, 0.15)
          }

          Flickable {
            id: bodyFlick
            width: parent.width
            height: root.readerH
            contentWidth: width
            contentHeight: bodyTextItem.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            function scrollBy(dy) {
              contentY = Math.max(0,
                Math.min(contentY + dy * Style.space(60),
                         Math.max(0, contentHeight - height)))
            }

            Text {
              id: bodyTextItem
              width: bodyFlick.width
              text: {
                if (root.bodyError !== "") return root.bodyError
                if (root.bodyText === "") return "Loading body…"
                return root.bodyText
              }
              // The body is neomd's markdown rendering of the mail. Qt's
              // MarkdownText does no script execution; links open via the
              // handler below, never inline.
              textFormat: root.bodyText === "" ? Text.PlainText : Text.MarkdownText
              wrapMode: Text.Wrap
              color: root.bodyText === "" ? Qt.darker(root.fg, 1.4) : root.fg
              linkColor: Color.accent
              font.family: root.fontFam
              font.pixelSize: Style.font.bodySmall
              font.italic: root.bodyText === "" && root.bodyError === ""
              onLinkActivated: function(link) {
                if (root.bar && (link.indexOf("http://") === 0 || link.indexOf("https://") === 0))
                  root.bar.run("omarchy-launch-browser " + Util.shellQuote(link))
              }
            }
          }
        }

        // ---- Footer hints.
        Text {
          width: parent.width
          text: root.reading !== null
            ? "j/k scroll · h back · o open neomd · Esc back"
            : "j/k move · l/Enter read · H/L tabs · o open neomd · r refresh"
          color: Qt.darker(root.fg, 1.7)
          font.family: root.fontFam
          font.pixelSize: Style.font.caption
        }
      }
    }
  }
}
