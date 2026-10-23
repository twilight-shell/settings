import QtQuick
import Twilight.Core

// A palette to choose: four of its colors and its name, a star when it is the
// one in use. `colors` is a palette, null for the one taken from the wallpaper.
Tap {
    id: root

    property var colors: null
    property string name: ""
    property bool chosen: false

    width: 150
    height: 96
    radius: 16
    lift: chosen ? 2 : 5
    fill: colors ? colors.surface : Theme.surface
    hoverFill: colors ? colors.surfaceHigh : Theme.surfaceHigh

    Column {
        anchors.centerIn: parent
        spacing: 10

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: -6

            Repeater {
                model: root.colors ? ["primary", "accent", "secondary", "star"].map(k => root.colors[k]) : []

                Rectangle {
                    required property var modelData

                    width: 26
                    height: 26
                    radius: 13
                    color: modelData
                    border.color: Theme.ink
                    border.width: 2
                }
            }

            // The wallpaper palette is whatever the picture gives.
            Text {
                visible: !root.colors
                text: "✧ ✦ ✧"
                color: Theme.primary
                font.pixelSize: 20
            }
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.name
            color: root.colors ? root.colors.text : Theme.text
            font.pixelSize: 13
            font.bold: root.chosen
        }
    }

    // The palette in use wears a star.
    Text {
        x: parent.width - 22
        y: -10
        text: "★"
        color: Theme.star
        font.pixelSize: 24
        style: Text.Outline
        styleColor: Theme.ink
        scale: root.chosen ? 1 : 0
        rotation: root.chosen ? 0 : -150

        Behavior on scale {
            NumberAnimation { duration: 420; easing.type: Easing.OutBack; easing.overshoot: 3 }
        }
        Behavior on rotation {
            NumberAnimation { duration: 480; easing.type: Easing.OutBack }
        }
    }
}
