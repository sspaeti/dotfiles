import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  // Each bar shows only the workspaces that belong to its own monitor, matching
  // the global split in ~/.config/hypr/monitors.lua (Omarchy 4.5 per-monitor
  // blocks are disabled there):
  //   2+ monitors -> external 1-5, laptop (eDP) 6-10
  //   1 monitor   -> 1-10 (laptop-only profile, or SUPER+ALT+1 laptop-off)
  // Plus any workspace that currently sits on this monitor outside that range
  // (moved by hand), so nothing gets hidden.
  readonly property var monitor: {
    var window = root.QsWindow.window
    var screen = window ? window.screen : null
    return screen ? Hyprland.monitorFor(screen) : Hyprland.focusedMonitor
  }
  readonly property string monitorName: root.monitor ? root.monitor.name : ""
  readonly property bool internal: /^(eDP|LVDS|DSI)/.test(root.monitorName)

  function enabledMonitorCount() {
    var count = 0
    var values = Hyprland.monitors.values
    for (var i = 0; i < values.length; i++) {
      var ipc = values[i].lastIpcObject
      if (values[i].name === "FALLBACK") continue
      if (ipc && (ipc.disabled === true || (ipc.mirrorOf && ipc.mirrorOf !== "none"))) continue
      count++
    }
    return count
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  function workspaceIds() {
    var first = 1
    var last = 10
    if (root.enabledMonitorCount() > 1) {
      first = root.internal ? 6 : 1
      last = root.internal ? 10 : 5
    }

    var ids = []
    for (var id = first; id <= last; id++) ids.push(id)

    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      var ws = values[i]
      if (ws.id > 0 && ws.id <= 10 && ids.indexOf(ws.id) === -1
          && ws.monitor && ws.monitor.name === root.monitorName) {
        ids.push(ws.id)
      }
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        // The workspace visible on THIS monitor, focused or not.
        readonly property bool shown: root.monitor !== null && root.monitor.activeWorkspace !== null && root.monitor.activeWorkspace.id === modelData

        bar: root.bar
        text: shown ? "󱓻" : (modelData === 10 ? "0" : String(modelData))
        opacity: occupied || shown ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
