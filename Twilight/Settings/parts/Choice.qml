import QtQuick
import Twilight.Core

// Pick one of a few options shown as pills; the chosen one is lit.
// options: [{ value, label }]
Row {
    id: root

    property var options: []
    property var value

    signal picked(var value)

    spacing: 8

    Repeater {
        model: root.options

        Tap {
            required property var modelData

            readonly property bool chosen: modelData.value === root.value

            implicitWidth: label.implicitWidth + 26
            implicitHeight: 30
            lift: chosen ? 1 : 3
            fill: chosen ? Theme.accent : Theme.surfaceHigh
            hoverFill: chosen ? Theme.accent : Theme.border
            onClicked: root.picked(modelData.value)

            StyledText {
                id: label

                anchors.centerIn: parent
                text: modelData.label
                font.pixelSize: 12
                font.bold: chosen
            }
        }
    }
}
