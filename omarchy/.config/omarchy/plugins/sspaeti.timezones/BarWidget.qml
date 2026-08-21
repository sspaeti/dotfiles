import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

// World-clock pill: a globe icon that expands to the client zones' current
// times on hover; left click opens the worldtimebuddy-style hour grid.
BarWidget {
  id: root
  moduleName: "sspaeti.timezones"

  // Sanitized because WidgetButton's internal Text uses AutoText, which
  // would rich-text-parse a crafted setting.
  readonly property string icon: Model.plainText(setting("icon", "󰇧"))
  readonly property string wtbUrl: setting("worldtimebuddyUrl", "https://www.worldtimebuddy.com/pdt-to-switzerland-bern")

  // Set "hoverExpand": false on the widget entry to keep the pill a static
  // icon — the expansion shifts neighboring bar widgets, which not everyone
  // wants.
  readonly property bool hoverExpand: setting("hoverExpand", true) === true

  readonly property string compact: panelLoader.item ? panelLoader.item.compactLabel : ""
  readonly property bool expanded: hoverExpand && !vertical && button.tooltipHovered && compact !== ""

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  function refresh() {
    if (panelLoader.item && panelLoader.item.refresh) panelLoader.item.refresh()
  }

  function togglePanel() {
    if (panelLoader.item && panelLoader.item.toggle) panelLoader.item.toggle()
  }

  // Shape contract for shell.summon/hide/toggle routing (Bar.findPanelWidget
  // requires open/close/opened on the bar-widget root).
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

  function open() {
    if (panelLoader.item && panelLoader.item.openFromHotkey) panelLoader.item.openFromHotkey()
  }

  function close() {
    if (panelLoader.item && panelLoader.item.close) panelLoader.item.close()
  }

  // Forwarded so this widget can stand in for the panel as the bar's popout
  // identity: Bar.requestPopout prefers closeForPopoutSwitch over close, and
  // KeyboardPanel reads popoutSwitchClosing back off its owner.
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
    target: "sspaeti.timezones"

    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.togglePanel() }
    function refresh(): void { root.refresh() }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.expanded ? root.icon + "   " + root.compact : root.icon
    tooltipText: ""

    onPressed: function(b) {
      if (!root.bar) return
      if (b === Qt.RightButton) root.bar.run("omarchy-launch-browser " + Util.shellQuote(root.wtbUrl))
      else if (b === Qt.MiddleButton) root.refresh()
      else root.togglePanel()
    }
  }
}
