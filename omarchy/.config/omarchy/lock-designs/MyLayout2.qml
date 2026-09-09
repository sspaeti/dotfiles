// My Layout — made with the lock screen designer.
// Open it there again with E in the explorer (omarchy-shell lock explore).
// Everything below the layout line is generated from it: edit the code by
// hand and the next save from the designer replaces it.
// designer:1:{"v":1,"name":"My Layout","nodes":[{"id":"n1","kind":"wallpaper","anchor":"center","dx":0,"dy":0,"w":0,"h":0,"spec":{"blur":0.85,"dim":0.08,"vignette":true}},{"id":"n2","kind":"clock","anchor":"center","dx":0,"dy":-170,"w":0,"h":0,"spec":{"format":"HH:mm","size":120,"weight":600,"color":"text","alpha":1,"spacing":-2,"align":"center","caps":false,"shadow":true}},{"id":"n3","kind":"date","anchor":"center","dx":0,"dy":-60,"w":0,"h":0,"spec":{"format":"dddd, d MMMM","size":26,"weight":400,"color":"text","alpha":0.85,"spacing":1,"align":"center","caps":false,"shadow":true}},{"id":"n4","kind":"password","anchor":"center","dx":0,"dy":40,"w":400,"h":60,"spec":{"placeholder":"Enter password","glyph":true,"fontScale":1,"align":"center"}},{"id":"n5","kind":"status","anchor":"center","dx":0,"dy":110,"w":0,"h":0,"spec":{"text":"Enter your password to unlock","size":16,"weight":400,"color":"placeholder","alpha":1,"spacing":0,"align":"center","caps":false,"shadow":false,"attempts":true}}]}
import QtQuick
import QtQuick.Effects
import qs.Commons
import "../plugins/io.github.sirjul1337.lock-explorer/designs"

DesignBase {
  id: lock
  inputItem: n4.inputItem

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onClicked: { lock.wakeRequested(); lock.forcePasswordFocus() }
    onPositionChanged: lock.wakeRequested()
  }

  // Wallpaper
  DesignerItem {
    id: n1
    lock: lock
    kind: "wallpaper"
    fillParent: true
    spec: ({"blur":0.85,"dim":0.08,"vignette":true})
  }

  // Clock
  DesignerItem {
    id: n2
    lock: lock
    kind: "clock"
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.horizontalCenterOffset: 0
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: -170
    spec: ({"format":"HH:mm","size":120,"weight":600,"color":"text","alpha":1,"spacing":-2,"align":"center","caps":false,"shadow":true})
  }

  // Date
  DesignerItem {
    id: n3
    lock: lock
    kind: "date"
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.horizontalCenterOffset: 0
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: -60
    spec: ({"format":"dddd, d MMMM","size":26,"weight":400,"color":"text","alpha":0.85,"spacing":1,"align":"center","caps":false,"shadow":true})
  }

  // Password box
  DesignerItem {
    id: n4
    lock: lock
    kind: "password"
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.horizontalCenterOffset: 0
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 40
    fixedWidth: 400
    fixedHeight: 60
    spec: ({"placeholder":"Enter password","glyph":true,"fontScale":1,"align":"center"})
  }

  // Status line
  DesignerItem {
    id: n5
    lock: lock
    kind: "status"
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.horizontalCenterOffset: 0
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 110
    spec: ({"text":"Enter your password to unlock","size":16,"weight":400,"color":"placeholder","alpha":1,"spacing":0,"align":"center","caps":false,"shadow":false,"attempts":true})
  }
}
