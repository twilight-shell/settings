import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Twilight.Core
import "parts"

// Settings window: tabs on the left, the page on the right. Everything applies
// as it's changed and is saved to the component's own file in
// ~/.config/twilight-shell/. The tabs come from the schemas the installed
// components ship, see Schemas.qml.
//
// IPC: `qs -c settings ipc call settings toggle`, `settings open <tab>`
PanelWindow {
    id: window

    property bool opened: false
    // Name of the output to open on; the first screen when empty or unknown.
    // The compositor is the host's business, so the host sets it.
    property string outputName: ""

    function open(name: string): void {
        if (name !== "" && tabs.some(t => t.key === name)) {
            tab = name;
            shownTab = name;
        }
        opened = true;
    }

    function close(): void {
        opened = false;
    }

    function toggle(): void {
        opened = !opened;
    }

    Schemas {
        id: schemas
    }

    readonly property var tabs: schemas.pages.map(p => ({ key: p.name, label: p.title, glyph: p.glyph, schema: p }))

    property string tab: ""
    property string shownTab: ""

    // The schemas are found a moment after startup.
    onTabsChanged: {
        if (tab === "" && tabs.length > 0) {
            tab = tabs[0].key;
            shownTab = tab;
        }
    }
    readonly property var shownSchema: tabs.find(t => t.key === shownTab)?.schema ?? tabs[0]?.schema ?? null
    // Set by hand, not bound to the animations, so the window never unmaps
    // for a frame between them.
    property bool shown: false
    // 0 = hidden, 1 = in place.
    property real show: 0
    property int slideDir: 1

    visible: shown
    screen: Quickshell.screens.find(s => s.name === window.outputName) ?? Quickshell.screens[0]
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "twilight-settings"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: window.opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    IpcHandler {
        target: "settings"

        function toggle(): void {
            window.toggle();
        }

        function open(tab: string): void {
            window.open(tab);
        }
    }

    Connections {
        target: window

        function onOpenedChanged() {
            if (window.opened) {
                closeAnim.stop();
                window.shown = true;
                openAnim.restart();
                Qt.callLater(() => keys.forceActiveFocus());
            } else {
                openAnim.stop();
                closeAnim.restart();
            }
        }
    }

    function openTab(key) {
        if (key === tab)
            return;
        const from = tabs.findIndex(t => t.key === tab);
        const to = tabs.findIndex(t => t.key === key);
        slideDir = to > from ? 1 : -1;
        tab = key;
        pageSwap.restart();
    }

    NumberAnimation {
        id: openAnim

        target: window
        property: "show"
        to: 1
        duration: 560
        easing.type: Easing.OutBack
        easing.overshoot: 1.2
    }

    SequentialAnimation {
        id: closeAnim

        NumberAnimation { target: window; property: "show"; to: 0; duration: 280; easing.type: Easing.InBack; easing.overshoot: 1.3 }
        ScriptAction { script: window.shown = false }
    }

    // Old page slides out, the new one springs in from the other side.
    SequentialAnimation {
        id: pageSwap

        ParallelAnimation {
            NumberAnimation { target: pageHolder; property: "x"; to: -window.slideDir * 40; duration: 120; easing.type: Easing.InQuad }
            NumberAnimation { target: pageHolder; property: "opacity"; to: 0; duration: 120 }
        }
        ScriptAction {
            script: {
                window.shownTab = window.tab;
                pageHolder.x = window.slideDir * 40;
            }
        }
        ParallelAnimation {
            NumberAnimation { target: pageHolder; property: "x"; to: 0; duration: 420; easing.type: Easing.OutBack; easing.overshoot: 1.4 }
            NumberAnimation { target: pageHolder; property: "opacity"; to: 1; duration: 220 }
        }
    }

    FocusScope {
        id: keys

        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: window.close()

        Rectangle {
            anchors.fill: parent
            color: Theme.alpha(Theme.bg, 0.6)
            opacity: Math.min(1, window.show)

            MouseArea {
                anchors.fill: parent
                onClicked: window.close()
            }
        }

        Item {
            id: card

            width: Math.min(1000, window.width - 80)
            height: Math.min(680, window.height - 120)
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2 + (1 - window.show) * 120
            opacity: Math.min(1, window.show * 1.5)
            scale: 0.9 + 0.1 * window.show

            // Swallow clicks so they don't close the window.
            MouseArea {
                anchors.fill: parent
            }

            Sticker {
                anchors.fill: parent
                radius: 26
                lift: 9
                fill: Theme.bg
            }

            RowLayout {
                anchors {
                    fill: parent
                    margins: 22
                }
                spacing: 22

                // Sidebar
                ColumnLayout {
                    // Layouts fill by default; the page should get the room.
                    Layout.fillWidth: false
                    Layout.preferredWidth: 210
                    Layout.maximumWidth: 210
                    Layout.fillHeight: true
                    spacing: 8

                    Text {
                        Layout.bottomMargin: 14
                        text: "✦ Settings"
                        color: Theme.star
                        font.family: Theme.font
                        font.pixelSize: 24
                        font.bold: true
                        style: Text.Outline
                        styleColor: Theme.ink
                    }

                    Repeater {
                        model: window.tabs

                        Tap {
                            id: tabButton

                            required property var modelData
                            readonly property bool current: window.tab === modelData.key

                            Layout.fillWidth: true
                            implicitHeight: 44
                            radius: 14
                            lift: current ? 1 : 3
                            fill: current ? Theme.secondary : Theme.surface
                            hoverFill: current ? Theme.secondary : Theme.surfaceHigh
                            onClicked: window.openTab(modelData.key)

                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                x: 16
                                spacing: 12

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: tabButton.modelData.glyph
                                    color: tabButton.current ? Theme.star : Theme.primary
                                    font.pixelSize: 16
                                    rotation: tabButton.current ? 0 : -20

                                    Behavior on rotation {
                                        NumberAnimation { duration: 400; easing.type: Easing.OutBack; easing.overshoot: 3 }
                                    }
                                }

                                StyledText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: tabButton.modelData.label
                                    font.pixelSize: 14
                                    font.bold: tabButton.current
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: "saved to\n~/.config/twilight-shell/"
                        color: Theme.muted
                        font.pixelSize: 10
                        wrapMode: Text.Wrap
                    }
                }

                // Page
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Item {
                        id: pageHolder

                        width: parent.width
                        height: parent.height

                        Loader {
                            anchors.fill: parent
                            active: window.shown && window.shownSchema !== null
                            sourceComponent: schemaPage
                        }
                    }
                }
            }
        }
    }

    Component {
        id: schemaPage

        SchemaPage {
            schema: window.shownSchema
        }
    }
}
