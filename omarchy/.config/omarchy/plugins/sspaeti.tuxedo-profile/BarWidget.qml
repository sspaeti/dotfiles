import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "sspaeti.tuxedo-profile"

  // Cycle order for left-click. TCC "temp" profiles last until tccd restarts,
  // which is exactly the semantics we want from a bar toggle.
  readonly property var profiles: [
    { id: "__legacy_default__",           name: "Default" },
    { id: "__legacy_cool_and_breezy__",   name: "Cool and breezy" },
    { id: "__legacy_powersave_extreme__", name: "Powersave extreme" },
    { id: "__default_custom_profile__",   name: "TUXEDO Defaults" }
  ]

  // Tux penguin (nf-fa-linux, U+F17C) — TUXEDO's mascot. Active profile lives
  // in the tooltip.
  readonly property string icon: "\uf17c"

  property string activeName: ""
  property string activeId: ""

  function refresh() {
    if (!readProc.running) readProc.running = true
  }

  function cycleProfile() {
    var idx = 0
    for (var i = 0; i < profiles.length; i++)
      if (profiles[i].id === activeId) { idx = (i + 1) % profiles.length; break }
    setProc.profileId = profiles[idx].id
    setProc.running = true
  }

  visible: activeName !== ""
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // Read active profile from tccd over the system bus (works as regular user).
  Process {
    id: readProc
    command: ["busctl", "--system", "call",
      "com.tuxedocomputers.tccd", "/com/tuxedocomputers/tccd",
      "com.tuxedocomputers.tccd", "GetActiveProfileJSON", "--json=short"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var outer = JSON.parse(String(text || "").trim())
          var prof = JSON.parse(outer.data[0])
          root.activeName = prof.name || ""
          root.activeId = prof.id || ""
        } catch (e) {
          root.activeName = ""
          root.activeId = ""
        }
      }
    }
  }

  // SetTempProfileById is callable as regular user; lasts until tccd restart.
  Process {
    id: setProc
    property string profileId: ""
    command: ["busctl", "--system", "call",
      "com.tuxedocomputers.tccd", "/com/tuxedocomputers/tccd",
      "com.tuxedocomputers.tccd", "SetTempProfileById", "s", profileId]
    onExited: root.refresh()
  }

  Timer {
    interval: 15000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.icon
    slotSize: Style.bar.statusSlot
    fontSize: Style.font.caption
    tooltipText: "TCC: " + root.activeName
      + "\nLeft: cycle profile | Right: open TCC | Middle: restart tccd (unstick 600 MHz)"

    onPressed: function(b) {
      if (!root.bar) return
      if (b === Qt.RightButton) root.bar.run("tuxedo-control-center")
      // tccd restart clears the post-suspend 600 MHz CPPC lock; pkexec because
      // this runs from the bar with no terminal for a sudo prompt.
      else if (b === Qt.MiddleButton) root.bar.run("pkexec systemctl restart tccd")
      else root.cycleProfile()
    }
  }
}
