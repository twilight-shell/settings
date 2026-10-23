import QtQuick
import QtQuick.Layouts
import Twilight.Core

// Edits a palette of your own: its name and the four colors the palette is
// built from. The palette is in use while it is edited, so the whole shell,
// this window too, shows the result as the colors change.
Sticker {
    id: root

    required property string schemeId
    // The [palettes.<id>] table as Theme has it.
    required property var spec
    // The theme.toml the changes are written to.
    required property var config

    // The color row whose picker is open.
    property string openKey: ""

    // Changes made while dragging are written once they stop for a moment.
    property var pending: ({})

    readonly property var rows: [
        { key: "base", label: "Background", hint: "tints the background and the surfaces" },
        { key: "primary", label: "Primary", hint: "text accents, the light color" },
        { key: "accent", label: "Accent", hint: "the vivid color" },
        { key: "secondary", label: "Secondary", hint: "the mid color" }
    ]

    function change(key: string, value: string): void {
        pending[key] = value;
        flush.restart();
    }

    Layout.fillWidth: true
    implicitHeight: column.implicitHeight + 32
    radius: 16
    lift: 3
    fill: Theme.surface

    Timer {
        id: flush

        interval: 120
        onTriggered: {
            for (const key of Object.keys(root.pending))
                root.config.set(["palettes", root.schemeId, key], root.pending[key]);
            root.pending = ({});
        }
    }

    ColumnLayout {
        id: column

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 16
        }
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            StyledText {
                text: "Name"
                font.pixelSize: 14
                font.bold: true
            }

            Field {
                Layout.fillWidth: true
                value: root.spec.name ?? root.schemeId
                onCommitted: text => {
                    if (text.trim() !== "")
                        root.config.set(["palettes", root.schemeId, "name"], text.trim());
                }
            }
        }

        Repeater {
            model: root.rows

            ColumnLayout {
                id: colorRow

                required property var modelData
                readonly property bool open: root.openKey === modelData.key
                readonly property color shown: root.spec[modelData.key] ?? "#808080"

                Layout.fillWidth: true
                spacing: 10

                Tap {
                    Layout.fillWidth: true
                    implicitHeight: 40
                    radius: 12
                    lift: colorRow.open ? 1 : 3
                    fill: colorRow.open ? Theme.surfaceHigh : Theme.surface
                    hoverFill: Theme.surfaceHigh
                    onClicked: root.openKey = colorRow.open ? "" : colorRow.modelData.key

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 12
                        spacing: 12

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 24
                            height: 24
                            radius: 12
                            color: colorRow.shown
                            border.color: Theme.ink
                            border.width: 2
                        }

                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: colorRow.modelData.label
                            font.pixelSize: 13
                            font.bold: true
                        }

                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: colorRow.modelData.hint
                            color: Theme.muted
                            font.pixelSize: 11
                        }
                    }

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        text: String(colorRow.shown).toUpperCase()
                        color: Theme.muted
                        font.pixelSize: 11
                    }
                }

                Loader {
                    Layout.alignment: Qt.AlignHCenter
                    active: colorRow.open
                    visible: active

                    sourceComponent: ColorPicker {
                        value: colorRow.shown
                        onPicked: color => root.change(colorRow.modelData.key, String(color))
                    }
                }
            }
        }
    }
}
