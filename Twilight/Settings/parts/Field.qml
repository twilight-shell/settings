import QtQuick
import Twilight.Core

// A line of text. `committed` fires on Enter and when the field loses focus,
// not on every key, so half-typed values aren't saved. Enter also lets go of
// the focus and flashes "saved" in the field.
Sticker {
    id: root

    property string value: ""
    // Flash "saved" after a change was committed. Off where the change is
    // visible anyway.
    property bool notify: true

    signal committed(string value)

    // What was last committed, so Enter and the focus it lets go of don't
    // commit the same text twice.
    property string last: value

    implicitWidth: 260
    implicitHeight: 34
    radius: 12
    lift: 2
    fill: Theme.surfaceHigh
    edge: input.activeFocus ? Theme.primary : Theme.ink

    // A change from outside, say the file edited by hand, unless it is being typed.
    onValueChanged: {
        last = value;
        if (!input.activeFocus)
            input.text = value;
    }

    function commit(): void {
        if (input.text === last)
            return;
        last = input.text;
        committed(input.text);
        if (notify)
            flash.restart();
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
        onAccepted: {
            root.commit();
            focus = false;
        }
        onEditingFinished: root.commit()
    }

    // Over the text it covers, for a moment.
    Sticker {
        id: note

        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: noteText.implicitWidth + 16
        height: 22
        radius: 11
        lift: 2
        fill: Theme.accent
        opacity: 0
        scale: 0.8
        visible: opacity > 0

        StyledText {
            id: noteText

            anchors.centerIn: parent
            text: "✓ saved"
            font.pixelSize: 11
            font.bold: true
        }

        SequentialAnimation {
            id: flash

            ParallelAnimation {
                NumberAnimation { target: note; property: "opacity"; to: 1; duration: 140 }
                NumberAnimation { target: note; property: "scale"; to: 1; duration: 260; easing.type: Easing.OutBack; easing.overshoot: 2.5 }
            }
            PauseAnimation { duration: 1100 }
            NumberAnimation { target: note; property: "opacity"; to: 0; duration: 350 }
            ScriptAction { script: note.scale = 0.8 }
        }
    }
}
