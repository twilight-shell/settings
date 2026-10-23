import QtQuick
import QtQuick.Layouts
import Twilight.Core

// One setting: title and description on the left, its control on the right.
Item {
    id: root

    property string title
    property string description
    // Something that is wrong, in the accent color under the description.
    property string note
    default property alias control: slot.data

    Layout.fillWidth: true
    implicitHeight: Math.max(64, text.implicitHeight + 28)

    HoverHandler {
        id: hover
    }

    Sticker {
        anchors.fill: parent
        radius: 16
        lift: 3
        fill: hover.hovered ? Theme.surfaceHigh : Theme.surface
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 18
            rightMargin: 18
        }
        spacing: 18

        Column {
            id: text

            Layout.fillWidth: true
            spacing: 4

            StyledText {
                width: parent.width
                text: root.title
                font.pixelSize: 14
                font.bold: true
            }

            StyledText {
                width: parent.width
                visible: text !== ""
                text: root.description
                color: Theme.muted
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }

            StyledText {
                width: parent.width
                visible: root.note !== ""
                text: "✧ " + root.note
                color: Theme.accent
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
        }

        Item {
            id: slot

            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
    }
}
