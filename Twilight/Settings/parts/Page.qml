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
        anchors {
            top: header.bottom
            topMargin: 18
            left: parent.left
            right: parent.right
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
}
