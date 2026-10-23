import QtQuick
import Twilight.Core

// Picks a color: a square for saturation and brightness, a bar for the hue and
// a field for the hex code. `picked` fires as the color changes, while dragging
// too; `value` is where the color is shown from.
Item {
    id: root

    property color value: "#ffffff"

    signal picked(color color)

    property real hue: 0
    property real sat: 0
    property real val: 1

    readonly property color current: Qt.hsva(hue, sat, val, 1)
    readonly property bool dragging: squareMouse.pressed || hueMouse.pressed

    implicitWidth: 240
    implicitHeight: square.height + hueBar.height + hex.height + 24

    // Follow `value` when it was changed from outside, not while it is being
    // dragged: the changes it made itself come back a moment later.
    function sync(): void {
        if (dragging || String(current) === String(value))
            return;
        // Greys have no hue: keep the one that was set.
        if (value.hsvHue >= 0)
            hue = value.hsvHue;
        sat = value.hsvSaturation;
        val = value.hsvValue;
    }

    function emit(): void {
        picked(current);
    }

    onValueChanged: sync()
    Component.onCompleted: sync()

    function clamp(v: real): real {
        return Math.max(0, Math.min(1, v));
    }

    // Saturation left to right, brightness top to bottom.
    Rectangle {
        id: square

        width: parent.width
        height: 140
        radius: 8
        border.color: Theme.ink
        border.width: 2
        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop { position: 0; color: "white" }
            GradientStop { position: 1; color: Qt.hsva(root.hue, 1, 1, 1) }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: 6
            gradient: Gradient {
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 1; color: "black" }
            }
        }

        Rectangle {
            x: root.sat * (square.width - 4) - width / 2 + 2
            y: (1 - root.val) * (square.height - 4) - height / 2 + 2
            width: 16
            height: 16
            radius: 8
            color: root.current
            border.color: "white"
            border.width: 3
        }

        MouseArea {
            id: squareMouse

            anchors.fill: parent
            // The page scrolls under a drag unless this keeps it.
            preventStealing: true
            onPressed: mouse => move(mouse)
            onPositionChanged: mouse => move(mouse)

            function move(mouse): void {
                root.sat = root.clamp((mouse.x - 2) / (width - 4));
                root.val = 1 - root.clamp((mouse.y - 2) / (height - 4));
                root.emit();
            }
        }
    }

    Rectangle {
        id: hueBar

        y: square.height + 10
        width: parent.width
        height: 18
        radius: 9
        border.color: Theme.ink
        border.width: 2
        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop { position: 0 / 6; color: Qt.hsva(0 / 6, 1, 1, 1) }
            GradientStop { position: 1 / 6; color: Qt.hsva(1 / 6, 1, 1, 1) }
            GradientStop { position: 2 / 6; color: Qt.hsva(2 / 6, 1, 1, 1) }
            GradientStop { position: 3 / 6; color: Qt.hsva(3 / 6, 1, 1, 1) }
            GradientStop { position: 4 / 6; color: Qt.hsva(4 / 6, 1, 1, 1) }
            GradientStop { position: 5 / 6; color: Qt.hsva(5 / 6, 1, 1, 1) }
            GradientStop { position: 6 / 6; color: Qt.hsva(0, 1, 1, 1) }
        }

        Rectangle {
            x: root.hue * (hueBar.width - 4) - width / 2 + 2
            anchors.verticalCenter: parent.verticalCenter
            width: 14
            height: 24
            radius: 7
            color: Qt.hsva(root.hue, 1, 1, 1)
            border.color: "white"
            border.width: 3
        }

        MouseArea {
            id: hueMouse

            anchors.fill: parent
            preventStealing: true
            onPressed: mouse => move(mouse)
            onPositionChanged: mouse => move(mouse)

            function move(mouse): void {
                root.hue = Math.min(0.9999, root.clamp((mouse.x - 2) / (width - 4)));
                root.emit();
            }
        }
    }

    Row {
        y: hueBar.y + hueBar.height + 10
        spacing: 10

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            height: 34
            radius: 10
            color: root.current
            border.color: Theme.ink
            border.width: 2
        }

        Field {
            id: hex

            anchors.verticalCenter: parent.verticalCenter
            // A Row doesn't use the implicit size.
            width: 110
            height: implicitHeight
            // The swatch next to it changes, that is the answer.
            notify: false
            value: String(root.current).toUpperCase()
            onCommitted: text => {
                if (!/^#[0-9a-fA-F]{6}$/.test(text))
                    return;
                const c = Qt.color(text);
                root.hue = c.hsvHue >= 0 ? c.hsvHue : root.hue;
                root.sat = c.hsvSaturation;
                root.val = c.hsvValue;
                root.emit();
            }
        }
    }
}
