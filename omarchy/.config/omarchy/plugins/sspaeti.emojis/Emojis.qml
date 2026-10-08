// sspaeti.emojis — clone of Omarchy's built-in emoji picker (omarchy.emojis)
// with two local changes:
//   1. Copy-only by default: Enter/click copies via wl-copy, Shift+Enter/
//      Shift+click types via wtype. Never calls omarchy-menu-emoji-insert.
//   2. A "Nerd Fonts" tab (Tab / Ctrl+T toggles, header tabs clickable).
//      The tab, its grep-streamed search and nerdfonts.tsv are adapted from
//      "Emojis & Nerd Fonts for Omarchy" by farangkao, MIT licensed:
//        https://github.com/farangkao/omarchy-emojis-nerd
//      See THIRD_PARTY_NOTICES.md next to this file.
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui
import "EmojiSearch.js" as EmojiSearch

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null

  readonly property string pluginDir: Quickshell.env("HOME") + "/.config/omarchy/plugins/sspaeti.emojis"

  property bool opened: false
  property string filterText: ""
  property int selectedIndex: 0
  property bool cursorActive: false
  property var emojis: []
  property var filteredEmojis: []

  // "emoji" (default on every open) or "nerd". Tab / Ctrl+T toggles.
  property string mode: "emoji"
  readonly property var modeOrder: ["emoji", "nerd"]

  // Nerd Font search streams nerdfonts.tsv (~10.6k rows, 1 MB) through grep
  // instead of holding the whole dataset in memory: only matched rows are
  // resident, and the emoji tab stays as fast as stock.
  property int nerdSearchSeq: 0
  property int nerdRunningSeq: 0
  property var nerdActiveTokens: []
  property var nerdRows: []
  property var nerdPendingCmd: null
  readonly property string tsvPath: root.pluginDir + "/nerdfonts.tsv"

  // Shares the [menu] surface tokens — themes that style the menu also
  // style emojis. Selected-cell colors composed in the
  // singleton so consumers drop them straight into Rectangle bindings.
  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Color.menu.scrim
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
  readonly property int cornerRadius: Style.cornerRadius
  property string fontFamily: Style.font.menuFamily
  property int contentMargin: Style.spacing.panelPadding
  property int headerHeight: Math.max(Style.space(34), Style.font.title + Style.spacing.controlPaddingY * 2)
  property int contentSpacing: Style.spacing.md
  property int cardWidth: Math.min(Style.space(400), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(500), panel.height - Style.gapsOut * 2)

  property int cellWidth: Math.max(Style.space(44), Style.font.display + Style.spacing.md)
  property int cellHeight: Math.max(Style.space(44), Style.font.display + Style.spacing.md)
  property int columns: Math.floor((cardWidth - contentMargin * 2) / cellWidth)

  // Glyph-name footer, Nerd Fonts tab only.
  property int footerHeight: root.mode === "nerd" ? Style.space(26) : 0

  function open(payloadJson) {
    root.opened = true
    root.mode = "emoji"
    root.filterText = ""
    root.selectedIndex = 0
    root.cursorActive = true
    root.rebuildDisplay()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.emojis")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function loadEmojis(raw) {
    root.emojis = EmojiSearch.parseEmojis(raw)
    if (root.opened) root.rebuildDisplay()
  }

  function rebuildDisplay() {
    if (root.mode === "nerd") {
      root.selectedIndex = 0
      nerdSearchDebounce.restart()
      return
    }
    fillDisplay(EmojiSearch.filterEmojis(root.emojis, root.filterText, 1000))
  }

  function fillDisplay(out) {
    root.filteredEmojis = out

    displayModel.clear()
    for (var j = 0; j < out.length; j++) {
      displayModel.append({ emoji: out[j].e, index: j, name: (out[j].n || "") })
    }

    if (displayModel.count === 0) selectedIndex = 0
    else if (selectedIndex >= displayModel.count) selectedIndex = displayModel.count - 1
    else if (selectedIndex < 0) selectedIndex = 0
    cursorActive = displayModel.count > 0

    Qt.callLater(function() {
      if (displayModel.count > 0) resultGrid.positionViewAtIndex(root.selectedIndex, GridView.Contain)
    })
  }

  function runNerdSearch() {
    var tokens = EmojiSearch.queryTokens(root.filterText)
    root.nerdSearchSeq++

    var cmd
    if (tokens.length === 0) {
      cmd = ["/usr/bin/head", "-n", "1000", root.tsvPath]
    } else {
      // The longest token is the cheapest grep prefilter; the exact
      // token-AND over keywords runs in JS once the rows arrive.
      tokens.sort(function(a, b) { return b.length - a.length })
      cmd = ["/usr/bin/grep", "-i", "-F", "--", tokens[0], root.tsvPath]
    }

    if (nerdProc.running) {
      root.nerdPendingCmd = cmd
      nerdProc.running = false
      return
    }
    startNerdProc(cmd)
  }

  function startNerdProc(cmd) {
    root.nerdRows = []
    root.nerdActiveTokens = EmojiSearch.queryTokens(root.filterText)
    root.nerdRunningSeq = root.nerdSearchSeq
    nerdProc.command = cmd
    nerdProc.running = true
  }

  function select(delta) {
    if (displayModel.count === 0) return
    if (!cursorActive) {
      cursorActive = true
      selectedIndex = delta < 0 ? displayModel.count - 1 : 0
    } else {
      selectedIndex = (selectedIndex + delta + displayModel.count) % displayModel.count
    }
    resultGrid.positionViewAtIndex(selectedIndex, GridView.Contain)
  }

  function selectRow(delta) {
    if (displayModel.count === 0) return
    if (!cursorActive) {
      cursorActive = true
      selectedIndex = delta < 0 ? displayModel.count - 1 : 0
      resultGrid.positionViewAtIndex(selectedIndex, GridView.Contain)
      return
    }
    var newIndex = selectedIndex + delta * columns
    if (newIndex < 0) newIndex = 0
    if (newIndex >= displayModel.count) newIndex = displayModel.count - 1
    selectedIndex = newIndex
    resultGrid.positionViewAtIndex(selectedIndex, GridView.Contain)
  }

  function selectPage(delta) {
    if (displayModel.count === 0) return
    if (!cursorActive) {
      cursorActive = true
      selectedIndex = delta < 0 ? displayModel.count - 1 : 0
      resultGrid.positionViewAtIndex(selectedIndex, GridView.Contain)
      return
    }
    var visibleRows = Math.max(1, Math.floor(resultGrid.height / cellHeight))
    var newIndex = selectedIndex + delta * columns * visibleRows
    if (newIndex < 0) newIndex = 0
    if (newIndex >= displayModel.count) newIndex = displayModel.count - 1
    selectedIndex = newIndex
    resultGrid.positionViewAtIndex(selectedIndex, GridView.Contain)
  }

  function setMode(nextMode) {
    if (root.mode === nextMode) return
    root.mode = nextMode
    // Keep the filter across switches so the same query is compared in
    // both datasets.
    root.selectedIndex = 0
    root.cursorActive = true
    root.rebuildDisplay()
  }

  function toggleMode() {
    root.setMode(root.modeOrder[(root.modeOrder.indexOf(root.mode) + 1) % root.modeOrder.length])
  }

  function setFilter(nextFilter) {
    root.filterText = nextFilter
    root.selectedIndex = 0
    root.cursorActive = true
    root.rebuildDisplay()
  }

  function activateIndex(index, paste) {
    if (index < 0 || index >= displayModel.count) return
    var row = displayModel.get(index)
    root.applySelected(row.emoji, paste)
  }

  function applySelected(emoji, paste) {
    if (!emoji) return
    root.dismiss()
    if (paste)
      // Type the emoji directly via wtype (after focus returns to the app) —
      // avoids omarchy-menu-emoji-insert's Shift+Insert race that pastes stale
      // clipboard content. Also copies it as a fallback.
      Quickshell.execDetached(["sh", "-c", 'printf %s "$1" | wl-copy --type text/plain; sleep 0.2; wtype "$1"', "emoji-paste", emoji])
    else
      // Copy only — no wtype Shift+Insert, paste manually
      Quickshell.execDetached(["wl-copy", "--type", "text/plain", emoji])
  }

  ListModel { id: displayModel }

  FileView {
    path: root.pluginDir + "/emojis.json"
    watchChanges: true
    onLoaded: root.loadEmojis(text())
    onFileChanged: reload()
  }

  Timer {
    id: nerdSearchDebounce
    interval: 160
    onTriggered: root.runNerdSearch()
  }

  Process {
    id: nerdProc
    command: ["/usr/bin/true"]

    stdout: SplitParser {
      onRead: function(data) { root.nerdRows.push(data) }
    }

    onExited: function(exitCode) {
      if (root.nerdPendingCmd) {
        // A SIGTERM from a superseded search is still settling; the
        // queued run starts once this exit finishes.
        var cmd = root.nerdPendingCmd
        root.nerdPendingCmd = null
        Qt.callLater(function() { root.startNerdProc(cmd) })
        return
      }
      // Stale results (mode switched away, newer keystrokes, or a kill)
      // are dropped by the sequence check.
      if (root.mode !== "nerd" || root.nerdRunningSeq !== root.nerdSearchSeq) return
      root.fillDisplay(EmojiSearch.filterTsvRows(root.nerdRows, root.nerdActiveTokens, 1000))
      root.nerdRows = []
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-emojis"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_Escape) {
            if (root.filterText) root.setFilter("")
            else root.dismiss()
            event.accepted = true
          } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab
                     || (event.key === Qt.Key_T && event.modifiers === Qt.ControlModifier)) {
            // Tab / Shift+Tab / Ctrl+T: flip between Emojis and Nerd Fonts.
            root.toggleMode()
            event.accepted = true
          } else if (Util.editsFilter(event, root.filterText)) {
            root.setFilter(Util.editedFilter(event, root.filterText))
            event.accepted = true
          } else if (event.key === Qt.Key_Left) {
            root.select(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_Right) {
            root.select(1)
            event.accepted = true
          } else if (event.key === Qt.Key_Up) {
            root.selectRow(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_Down) {
            root.selectRow(1)
            event.accepted = true
          } else if (event.key === Qt.Key_PageUp) {
            root.selectPage(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_PageDown) {
            root.selectPage(1)
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            // Enter copies to clipboard; Shift+Enter pastes directly
            if (root.cursorActive) root.activateIndex(root.selectedIndex, (event.modifiers & Qt.ShiftModifier) !== 0)
            else if (displayModel.count > 0) root.cursorActive = true
            event.accepted = true
          } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
            root.setFilter(root.filterText + event.text)
            event.accepted = true
          }
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: root.contentSpacing

        Row {
          id: tabBar
          width: parent.width
          height: root.headerHeight
          spacing: root.contentSpacing

          Repeater {
            model: [
              { key: "emoji", label: "Emojis" },
              { key: "nerd", label: "Nerd Fonts" }
            ]

            delegate: Rectangle {
              id: tab

              required property var modelData

              readonly property bool active: root.mode === modelData.key

              height: root.headerHeight
              width: tabLabel.implicitWidth + Style.spacing.controlPaddingX * 2
              radius: root.cornerRadius
              // Only the active tab gets a fill; the inactive one is plain
              // text so it doesn't read as a second highlighted choice.
              color: active ? root.selectedBackground : "transparent"

              Text {
                id: tabLabel
                anchors.centerIn: parent
                text: tab.modelData.label
                textFormat: Text.PlainText
                color: tab.active ? root.selectedText : root.foreground
                opacity: tab.active ? 1 : 0.7
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.setMode(tab.modelData.key)
              }
            }
          }
        }

        Rectangle {
          width: parent.width
          height: root.headerHeight
          radius: root.cornerRadius
          color: "transparent"

          Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.filterText
                  || (root.mode === "nerd" ? "Search Nerd Fonts…  (Tab: emojis)"
                                           : "Search emojis…  (Tab: Nerd Fonts)")
            textFormat: Text.PlainText
            color: root.foreground
            opacity: root.filterText ? 1 : 0.58
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            elide: Text.ElideRight
          }
        }

        Item {
          width: parent.width
          height: parent.height - root.headerHeight * 2 - root.footerHeight
                  - root.contentSpacing * (root.footerHeight > 0 ? 3 : 2)

          GridView {
            id: resultGrid
            anchors.fill: parent
            model: displayModel
            clip: true
            cellWidth: root.cellWidth
            cellHeight: root.cellHeight
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
              required property int index
              required property string emoji

              readonly property bool hasCursor: root.cursorActive && index === root.selectedIndex

              width: root.cellWidth
              height: root.cellHeight
              radius: root.cornerRadius
              color: hasCursor ? root.selectedBackground : "transparent"

              Text {
                text: parent.emoji
                textFormat: Text.PlainText
                // Nerd Font glyphs are monochrome outlines that follow the
                // text color (color emojis ignore it), so theme both modes.
                color: hasCursor ? root.selectedText : root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.display
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
              }

              MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: if (containsMouse) {
                  root.cursorActive = true
                  root.selectedIndex = index
                }
                onClicked: function(mouse) {
                  root.cursorActive = true
                  root.selectedIndex = index
                  // Click copies to clipboard; Shift+Click pastes directly
                  root.activateIndex(index, (mouse.modifiers & Qt.ShiftModifier) !== 0)
                }
              }
            }
          }

          Column {
            anchors.centerIn: parent
            spacing: Style.space(8)
            visible: displayModel.count === 0

            Text {
              text: "󰈉"
              color: root.selectedText
              opacity: 0.8
              font.family: root.fontFamily
              font.pixelSize: Style.font.displayLarge
              horizontalAlignment: Text.AlignHCenter
              width: parent.width
            }

            Text {
              text: "No matches for “" + root.filterText + "”"
              textFormat: Text.PlainText
              color: root.foreground
              opacity: 0.7
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              horizontalAlignment: Text.AlignHCenter
              width: parent.width
            }
          }
        }

        Rectangle {
          width: parent.width
          height: root.footerHeight
          visible: height > 0
          radius: root.cornerRadius
          color: "transparent"

          Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Style.space(8)
            text: {
              if (root.mode !== "nerd" || !root.cursorActive || displayModel.count === 0)
                return ""
              var row = displayModel.get(root.selectedIndex)
              return row && row.name ? row.name + "   " + row.emoji : ""
            }
            textFormat: Text.PlainText
            color: root.foreground
            opacity: 0.8
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            elide: Text.ElideRight
          }
        }
      }
    }
  }
}
