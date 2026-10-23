import QtQuick
import Twilight.Core

// A star slider over a numeric range, snapped to `step`, with its value
// shown next to it. Emits moved(value) in the range's own units.
Row {
    id: root

    property real value
    property real from: 0
    property real to: 1
    property real step: 1
    property string suffix: ""
    property int decimals: 0

    signal moved(real value)

    spacing: 12

    StarSlider {
        anchors.verticalCenter: parent.verticalCenter
        width: 200
        value: (root.value - root.from) / (root.to - root.from)
        onMoved: v => {
            const raw = root.from + v * (root.to - root.from);
            const snapped = Math.round(raw / root.step) * root.step;
            root.moved(Number(snapped.toFixed(root.decimals)));
        }
    }

    RollText {
        anchors.verticalCenter: parent.verticalCenter
        width: 52
        text: root.value.toFixed(root.decimals) + root.suffix
        color: Theme.text
        pixelSize: 13
        bold: true
        duration: 200
    }
}
