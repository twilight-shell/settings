import QtQuick
import Twilight.Core

// A line of text. `committed` fires on Enter and when the field loses focus,
// not on every key, so half-typed values aren't saved.
Sticker {
    id: root

    property string value: ""

    signal committed(string value)

    implicitWidth: 260
    implicitHeight: 34
    radius: 12
    lift: 2
    fill: Theme.surfaceHigh
    edge: input.activeFocus ? Theme.primary : Theme.ink

    // A change from outside, say the file edited by hand, unless it is being typed.
    onValueChanged: {
        if (!input.activeFocus)
            input.text = value;
    }

    TextInput {
        id: input

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 12
            rightMargin: 12
        }
        color: Theme.text
        selectionColor: Theme.secondary
        font.family: Theme.font
        font.pixelSize: 13
        clip: true
        selectByMouse: true
        Component.onCompleted: text = root.value
        onEditingFinished: root.committed(text)
    }
}
