// Customized copy of the Poster design. Edit it here or with:
//   omarchy-shell lock editDesign my-poster
import QtQuick
import QtQuick.Effects
import qs.Commons
import "../plugins/io.github.sirjul1337.lock-explorer/designs"

DesignBase {
  id: lock
  inputItem: field.input

  readonly property int margin: Math.round(Math.min(width, height) * 0.08)
  readonly property int bigSize: Math.round(Style.font.baseSize * 22)

  Wallpaper { anchors.fill: parent; lock: lock; blur: 0.0; dim: 0; vignetteTop: 0.2; vignetteMiddle: 0.15; vignetteBottom: 0.55 }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onClicked: { lock.wakeRequested(); lock.forcePasswordFocus() }
    onPositionChanged: lock.wakeRequested()
  }

  Column {
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.rightMargin: lock.margin
    anchors.topMargin: Math.round(lock.margin * 0.6)
    spacing: 6

    Column {
      anchors.right: parent.right
      spacing: -Math.round(lock.bigSize * 0.22)
      Text {
        anchors.right: parent.right
        text: Qt.formatTime(lock.now, "HH")
        color: Color.lock.text
        font.family: Style.font.family
        font.pixelSize: lock.bigSize
        font.weight: Font.Black
        font.letterSpacing: -8
        layer.enabled: true
        layer.effect: MultiEffect { shadowEnabled: true; shadowColor: Qt.rgba(0, 0, 0, 0.6); shadowBlur: 1.0; shadowVerticalOffset: 4 }
      }
      Text {
        anchors.right: parent.right
        text: Qt.formatTime(lock.now, "mm")
        color: Color.lock.borderActive
        font.family: Style.font.family
        font.pixelSize: lock.bigSize
        font.weight: Font.Black
        font.letterSpacing: -8
        layer.enabled: true
        layer.effect: MultiEffect { shadowEnabled: true; shadowColor: Qt.rgba(0, 0, 0, 0.6); shadowBlur: 1.0; shadowVerticalOffset: 4 }
      }
    }
    Item { width: 1; height: Math.round(lock.bigSize * 0.12) }
    Text {
      anchors.right: parent.right
      text: Qt.formatDate(lock.now, "dddd").toUpperCase()
      color: Color.lock.text
      font.family: Style.font.family
      font.pixelSize: Style.font.heading
      font.letterSpacing: 6
    }
    Text {
      anchors.right: parent.right
      text: Qt.formatDate(lock.now, "d MMMM yyyy").toUpperCase()
      color: lock.withAlpha(Color.lock.text, 0.7)
      font.family: Style.font.family
      font.pixelSize: Style.font.body
      font.letterSpacing: 4
    }
  }

  Column {
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    anchors.margins: lock.margin
    spacing: 14

    Row {
      spacing: 12
      Avatar {
        lock: lock
        width: 40
        fontSize: Style.font.heading
        anchors.verticalCenter: parent.verticalCenter
        shadow: false
      }
      Column {
        anchors.verticalCenter: parent.verticalCenter
        Text {
          text: lock.userName
          color: Color.lock.text
          font.family: Style.font.family
          font.pixelSize: Style.font.title
          font.weight: Font.DemiBold
        }
        Text {
          text: lock.errorState ? lock.failureMessage : (lock.authenticatingPassword ? "Checking…" : lock.hostName)
          textFormat: Text.PlainText
          color: lock.errorState ? Color.lock.textError : lock.withAlpha(Color.lock.text, 0.6)
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
        }
      }
    }

    PasswordField {
      id: field
      lock: lock
      width: 360
      height: 52
      textAlignment: TextInput.AlignLeft
      placeholder: "Password"
      color: lock.withAlpha(Color.lock.background, 0.7)
    }
  }
}
