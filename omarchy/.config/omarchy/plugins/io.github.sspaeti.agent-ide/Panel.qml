import QtQuick
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Agent-IDE panel: the sessions that need you, most urgent first (waiting, review, running), grouped by where
// they live (one block per Neovim, then tmux / other). Plain list, no settings. Enter or a click focuses the
// tmux pane of the session when there is one (jump.sh); rows are otherwise just information.
// Data and polling live in BarWidget.qml (hostWidget).
Panel {
  id: root
  moduleName: "io.github.sspaeti.agent-ide"
  ipcTarget: "io.github.sspaeti.agent-ide"
  manageIpc: false

  property var anchorItem: null
  property bool openedFromHotkey: false

  // The bar tracks the widget mounted in its slot, not this nested panel.
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

  // The bar may hand a PluginBarApi facade whose property is read-only: prefer the setter it exposes.
  function setCenterHoverRevealSuppressed(value) {
    if (root.bar && typeof root.bar.setCenterHoverRevealSuppressed === "function")
      root.bar.setCenterHoverRevealSuppressed(value)
    else if (root.bar && "centerHoverRevealSuppressed" in root.bar)
      root.bar.centerHoverRevealSuppressed = value
  }

  readonly property color fg: bar ? bar.foreground : "#e0e0e0"
  readonly property string fontFam: bar ? bar.fontFamily : Style.font.family

  // ---- Data from the widget.
  readonly property var agg: hostWidget ? hostWidget.agg : null
  readonly property var rows: agg ? agg.rows : []
  readonly property var groups: agg ? agg.groups : []
  readonly property var palette: hostWidget ? hostWidget.colors : Model.FALLBACK_COLORS
  property int selIndex: 0
  property string selId: ""

  function stateColor(state) {
    return state === "waiting" ? palette.violet : state === "review" ? palette.orange : palette.yellow
  }

  function stateLabel(row) {
    if (row.state === "waiting") return row.reason !== "" ? row.reason : "input"
    return row.state === "review" ? "review" : "running"
  }

  function refresh() {
    if (hostWidget) hostWidget.refresh()
  }

  function activate(row) {
    if (!row || !hostWidget || row.jumpPids.length === 0) return
    hostWidget.jump(row.jumpPids)
    root.close()
  }

  function select(i) {
    selIndex = i
    selId = rows.length > i ? rows[i].id : ""
  }

  // Keep the highlight on the same session when rows reorder or disappear.
  onRowsChanged: selIndex = Model.selectedIndex(rows, selId, selIndex)
  onOpenedChanged: if (opened) {
    select(0)
    refresh()
  }

  readonly property real contentW: Style.space(460)
  readonly property real rowH: Style.space(38)

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
      // j/k move · Enter or l focus the tmux pane · r refresh · Esc close
      onMoveRequested: function(dx, dy) {
        if (dy !== 0 && root.rows.length > 0)
          root.select(Math.max(0, Math.min(root.selIndex + dy, root.rows.length - 1)))
        else if (dx > 0 && root.rows.length > 0)
          root.activate(root.rows[root.selIndex])
      }
      onActivateRequested: if (root.rows.length > 0) root.activate(root.rows[root.selIndex])
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "r" || t === "R") root.refresh()
      }

      Column {
        id: mainCol
        width: parent.width
        spacing: Style.space(10)

        // ---- Header: title and summary.
        Row {
          width: parent.width
          spacing: Style.space(8)

          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: Style.space(10)
            height: width
            radius: width / 2
            color: root.hostWidget ? root.hostWidget.dotColor : root.palette.green
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Agents"
            color: root.fg
            font.family: root.fontFam
            font.pixelSize: Style.font.body
            font.bold: true
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.agg ? Model.tooltip(root.agg) : ""
            textFormat: Text.PlainText
            color: Qt.darker(root.fg, 1.4)
            font.family: root.fontFam
            font.pixelSize: Style.font.caption
          }
        }

        Text {
          visible: root.rows.length === 0
          width: parent.width
          text: "No agent needs you."
          color: Qt.darker(root.fg, 1.4)
          font.family: root.fontFam
          font.pixelSize: Style.font.bodySmall
          font.italic: true
        }

        // ---- Groups: heading, then the rows of that group (rows are sorted by urgency).
        Repeater {
          model: root.groups

          Column {
            id: groupCol
            required property var modelData
            width: mainCol.width
            spacing: Style.space(2)

            Text {
              text: groupCol.modelData.label
              textFormat: Text.PlainText
              color: Qt.darker(root.fg, 1.5)
              font.family: root.fontFam
              font.pixelSize: Style.font.caption
              font.bold: true
            }

            Repeater {
              model: groupCol.modelData.rows

              Item {
                id: sessionRow
                required property var modelData
                readonly property bool sel: modelData.flat === root.selIndex
                readonly property bool jumpable: modelData.jumpPids.length > 0
                width: groupCol.width
                height: root.rowH

                Rectangle {
                  anchors.fill: parent
                  radius: Style.space(4)
                  color: sessionRow.sel ? Qt.alpha(Color.accent, 0.16)
                       : rowMouse.containsMouse ? Qt.alpha(root.fg, 0.06)
                       : "transparent"
                }

                MouseArea {
                  id: rowMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  enabled: true
                  cursorShape: sessionRow.jumpable ? Qt.PointingHandCursor : Qt.ArrowCursor
                  onClicked: {
                    root.select(sessionRow.modelData.flat)
                    root.activate(sessionRow.modelData)
                  }
                }

                Rectangle {
                  id: dot
                  anchors.left: parent.left
                  anchors.leftMargin: Style.space(8)
                  anchors.verticalCenter: parent.verticalCenter
                  width: Style.space(8)
                  height: width
                  radius: width / 2
                  color: root.stateColor(sessionRow.modelData.state)
                }

                Column {
                  anchors.left: dot.right
                  anchors.leftMargin: Style.space(10)
                  anchors.right: stateText.left
                  anchors.rightMargin: Style.space(8)
                  anchors.verticalCenter: parent.verticalCenter

                  Text {
                    width: parent.width
                    text: sessionRow.modelData.project !== "" ? sessionRow.modelData.project : "(no project)"
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    color: root.fg
                    font.family: root.fontFam
                    font.pixelSize: Style.font.bodySmall
                    font.bold: true
                  }

                  Text {
                    width: parent.width
                    text: sessionRow.modelData.title
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    color: Qt.darker(root.fg, 1.3)
                    font.family: root.fontFam
                    font.pixelSize: Style.font.caption
                  }
                }

                Text {
                  id: stateText
                  anchors.right: parent.right
                  anchors.rightMargin: Style.space(8)
                  anchors.verticalCenter: parent.verticalCenter
                  text: root.stateLabel(sessionRow.modelData)
                  textFormat: Text.PlainText
                  color: root.stateColor(sessionRow.modelData.state)
                  font.family: root.fontFam
                  font.pixelSize: Style.font.caption
                }
              }
            }
          }
        }

        Text {
          readonly property int hidden: root.agg ? root.agg.waiting + root.agg.review + root.agg.busy - root.rows.length : 0
          visible: hidden > 0
          width: parent.width
          text: "… and " + hidden + " more"
          color: Qt.darker(root.fg, 1.4)
          font.family: root.fontFam
          font.pixelSize: Style.font.caption
        }

        Text {
          width: parent.width
          text: "j/k move · Enter focus tmux pane · r refresh · Esc close"
          color: Qt.darker(root.fg, 1.7)
          font.family: root.fontFam
          font.pixelSize: Style.font.caption
        }
      }
    }
  }
}
