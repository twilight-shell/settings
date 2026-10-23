import QtQuick
import QtQuick.Layouts
import Twilight.Core

// A settings page: title, subtitle and a scrolling column of options.
Item {
    id: root

    property string title
    property string subtitle
    default property alias content: column.data

    Column {
        id: header

        width: parent.width
        spacing: 4

        Text {
            text: root.title
            color: Theme.star
            font.family: Theme.font
            font.pixelSize: 26
            font.bold: true
            style: Text.Outline
            styleColor: Theme.ink
        }

        StyledText {
            width: parent.width
            text: root.subtitle
            color: Theme.muted
            font.pixelSize: 12
            wrapMode: Text.Wrap
        }
    }

    Flickable {
        id: flick

        anchors {
            top: header.bottom
            topMargin: 18
            left: parent.left
            right: parent.right
            rightMargin: 18
            bottom: parent.bottom
        }
        contentHeight: column.implicitHeight + 16
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: column

            width: parent.width - 6
            spacing: 12
        }
    }

    // A scroll bar to grab, for the mouse without a wheel too.
    Item {
        id: scrollbar

        anchors {
            top: flick.top
            bottom: flick.bottom
            right: parent.right
        }
        width: 12
        visible: flick.contentHeight > flick.height + 1

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: Theme.bg
            border.color: Theme.ink
            border.width: 2
        }

        Rectangle {
            id: handle

            readonly property real room: scrollbar.height - height

            x: 2
            width: parent.width - 4
            height: Math.max(36, flick.visibleArea.heightRatio * scrollbar.height)
            radius: 4
            color: handleMouse.pressed || handleMouse.containsMouse ? Theme.accent : Theme.primary

            Binding on y {
                when: !handleMouse.drag.active
                value: flick.visibleArea.yPosition * (scrollbar.height - handle.height) / Math.max(0.001, 1 - flick.visibleArea.heightRatio)
            }

            MouseArea {
                id: handleMouse

                anchors.fill: parent
                hoverEnabled: true
                drag.target: handle
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: handle.room
                onPositionChanged: {
                    if (drag.active && handle.room > 0)
                        flick.contentY = handle.y / handle.room * (flick.contentHeight - flick.height);
                }
            }
        }

        // A click on the track jumps a page up or down.
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: mouse => {
                const page = flick.height * 0.9;
                flick.contentY = Math.max(0, Math.min(flick.contentHeight - flick.height, flick.contentY + (mouse.y < handle.y ? -page : page)));
            }
        }
    }
}
