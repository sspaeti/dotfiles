import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Agent-IDE indicator: one coloured dot (green / yellow / orange / violet) and, when something needs you, a
// count next to it. Left click opens the panel, middle click refreshes. Owns the polling; Panel.qml only draws.
//
// Data: status files of the Neovim instances (collect.sh, every 2 s) and the Claude sessions outside Neovim
// (outside.sh = `claude agents --json`, every 5 s). Both run asynchronously, never overlapping themselves.
BarWidget {
  id: root
  moduleName: "io.github.sspaeti.agent-ide"

  readonly property int statusIntervalMs: 2000
  readonly property int outsideIntervalMs: 10000
  readonly property int outsideFailuresKept: 3 // keep the last list over this many failed polls (~15 s)

  // ---- State.
  property var files: []
  property var outside: []
  property int outsideFailures: 0
  property double nowSec: Date.now() / 1000
  property var colors: Model.FALLBACK_COLORS
  // Plain property, assigned only when the content changed: a fresh object on every tick would make the panel's
  // Repeaters rebuild all rows (hover flicker, lost clicks). The aggregate holds nothing derived from the time.
  property var agg: Model.aggregate([], [], 0)
  property string aggSig: ""
  readonly property string badge: Model.badge(agg)
  readonly property color dotColor: Model.colorFor(agg.level, colors)

  function recompute() {
    var a = Model.aggregate(files, outside, nowSec)
    var sig = JSON.stringify(a)
    if (sig === aggSig) return
    aggSig = sig
    agg = a
  }

  function scriptPath(name) {
    return Qt.resolvedUrl(name).toString().replace(/^file:\/\//, "")
  }

  function refresh() {
    pollStatus()
    pollOutside()
    themeFile.reload()
  }

  function pollStatus() {
    if (statusProc.running) return
    statusProc.command = ["bash", scriptPath("collect.sh")]
    statusProc.running = true
  }

  function pollOutside() {
    if (outsideProc.running) return
    outsideProc.command = ["bash", scriptPath("outside.sh")]
    outsideProc.running = true
  }

  // Focus the tmux pane of a session: the first pid that sits on a tmux pane tty wins (jump.sh).
  function jump(pids) {
    if (!root.bar || !pids || pids.length === 0) return
    var cmd = "bash " + Util.shellQuote(scriptPath("jump.sh"))
    for (var i = 0; i < pids.length; i++) cmd += " " + Number(pids[i])
    root.bar.run(cmd)
  }

  Process {
    id: statusProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.files = Model.parseStatusLines(text)
        root.nowSec = Date.now() / 1000
        root.recompute()
      }
    }
  }

  Process {
    id: outsideProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var list = Model.parseOutside(text)
        if (list !== null) {
          root.outside = list
          root.outsideFailures = 0
        } else {
          root.outsideFailures++
          // `claude` missing or failing: the source is empty after a few polls
          if (root.outsideFailures >= root.outsideFailuresKept) root.outside = []
        }
        root.recompute()
      }
    }
  }

  Timer {
    interval: root.statusIntervalMs
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      root.nowSec = Date.now() / 1000 // also ages out files while the script finds nothing new
      root.recompute()
      root.pollStatus()
    }
  }

  Timer {
    interval: root.outsideIntervalMs
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.pollOutside()
  }

  // Theme palette (green, yellow, orange, magenta from colors.toml). The theme directory is replaced on a theme
  // switch, which a file watcher can miss, so the file is simply read again once in a while.
  FileView {
    id: themeFile
    path: Color.currentThemePath + "/colors.toml"
    watchChanges: false
    printErrors: false
    onLoaded: root.colors = Model.parseThemeColors(text())
    onLoadFailed: root.colors = Model.FALLBACK_COLORS
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    onTriggered: themeFile.reload()
  }

  // ---- Panel plumbing, same contract as the other plugins (neomd).
  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  function togglePanel() {
    if (panelLoader.item && panelLoader.item.toggle) panelLoader.item.toggle()
  }

  // Shape contract for shell.summon/hide/toggle routing (the bar needs open/close/opened on the widget root).
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

  function open() {
    if (panelLoader.item && panelLoader.item.openFromHotkey) panelLoader.item.openFromHotkey()
  }

  function close() {
    if (panelLoader.item && panelLoader.item.close) panelLoader.item.close()
  }

  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

  function closeForPopoutSwitch() {
    if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  IpcHandler {
    target: "io.github.sspaeti.agent-ide"

    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.togglePanel() }
    function refresh(): void { root.refresh() }
  }

  // The button supplies size, hover tooltip and click handling; the dot and the count are drawn on top of it
  // (the stock label can only take the foreground or the urgent colour).
  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "●" // makes the button visible; its own label is hidden
    labelVisible: false
    fixedWidth: content.implicitWidth + Style.spaceReal(17)
    tooltipText: Model.tooltip(root.agg)

    onPressed: function(b) {
      if (b === Qt.MiddleButton) root.refresh()
      else root.togglePanel()
    }
  }

  Row {
    id: content
    anchors.centerIn: parent
    spacing: Style.spaceReal(5)

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: Style.spaceReal(10)
      height: width
      radius: width / 2
      color: root.dotColor

      Behavior on color {
        ColorAnimation { duration: 200 }
      }
    }

    Text {
      visible: root.badge !== ""
      anchors.verticalCenter: parent.verticalCenter
      text: root.badge
      textFormat: Text.PlainText
      color: root.dotColor
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.body
      font.bold: true
    }
  }
}
