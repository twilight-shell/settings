import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Twilight.Core
import "../parts"

// The wallpaper: live stars, or a picture from a folder. The picture is
// written to theme.toml, since the palette can take its colors from it, the
// rest to wallpaper.toml.
Page {
    id: page

    // Where wallpaper.defaults.toml is, so the settings it lacks read their defaults.
    property url defaults

    readonly property bool stars: config.get("live") === "stars"
    readonly property string folder: expand(config.get("dir") ?? "")

    title: "Wallpaper"
    subtitle: "The live LED star wall, or a picture from " + (folder === "" ? "a folder" : folder.replace(/^\/home\/[^/]+/, "~")) + "."

    function expand(path: string): string {
        return path.startsWith("~") ? Quickshell.env("HOME") + path.slice(1) : path;
    }

    ConfigFile {
        id: config

        name: "wallpaper"
        defaults: page.defaults
    }

    ConfigFile {
        id: theme

        name: "theme"
    }

    // Picks a picture, or none, and turns the live wallpaper off, since it
    // would cover the picture.
    function pick(path: string): void {
        theme.set("wallpaper", path);
        config.set("live", "");
    }

    Option {
        title: "Live stars"
        description: "An LED wall of glowing stars drifting across the screen, in the palette's colors."

        Toggle {
            checked: page.stars
            onToggled: checked => config.set("live", checked ? "stars" : "")
        }
    }

    Repeater {
        model: [
            { key: "stars.dot", title: "LED size", description: "Size of the dots the stars are made of.", from: 5, to: 16, step: 1, decimals: 0, suffix: "px" },
            { key: "stars.cell", title: "Star spacing", description: "Room each star gets; less means more, smaller stars.", from: 160, to: 520, step: 10, decimals: 0, suffix: "px" },
            { key: "stars.speed", title: "Drift speed", description: "", from: 0, to: 3, step: 0.1, decimals: 1, suffix: "×" },
            { key: "stars.glow", title: "Glow", description: "The haze spreading around the stars.", from: 0, to: 1, step: 0.05, decimals: 2, suffix: "" }
        ]

        Option {
            id: knob

            required property var modelData

            visible: page.stars
            title: modelData.title
            description: modelData.description

            Range {
                value: Number(config.get(knob.modelData.key)) || 0
                from: knob.modelData.from
                to: knob.modelData.to
                step: knob.modelData.step
                decimals: knob.modelData.decimals
                suffix: knob.modelData.suffix
                onMoved: v => config.set(knob.modelData.key, v)
            }
        }
    }

    Option {
        title: "Folder"
        description: "Where the pictures below, and the next and previous commands, come from."

        Field {
            value: String(config.get("dir") ?? "")
            onCommitted: value => config.set("dir", value.trim())
        }
    }

    StyledText {
        Layout.fillWidth: true
        Layout.topMargin: 6
        text: "PICTURES"
        color: Theme.muted
        font.pixelSize: 11
        font.letterSpacing: 1
    }

    FolderListModel {
        id: pictures

        folder: page.folder !== "" ? "file://" + page.folder : ""
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        showDirs: false
        sortField: FolderListModel.Name
    }

    StyledText {
        Layout.fillWidth: true
        visible: pictures.count === 0
        text: "✧ No pictures yet. Put some into " + (page.folder === "" ? "the folder" : page.folder) + " and they show up here."
        color: Theme.muted
        font.pixelSize: 12
        wrapMode: Text.Wrap
    }

    Flow {
        Layout.fillWidth: true
        spacing: 12

        // No wallpaper: just the palette's background color.
        Tap {
            readonly property bool chosen: !page.stars && Theme.wallpaper === ""

            width: 200
            height: 120
            radius: 14
            lift: chosen ? 2 : 5
            fill: Theme.bg
            hoverFill: Theme.surface
            onClicked: page.pick("")

            Column {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "✧"
                    color: Theme.muted
                    font.pixelSize: 28
                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "None"
                    color: Theme.muted
                    font.pixelSize: 13
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: "transparent"
                border.color: parent.chosen ? Theme.star : "transparent"
                border.width: 3
            }
        }

        Repeater {
            model: pictures

            Tap {
                id: thumb

                required property string filePath
                readonly property bool chosen: !page.stars && Theme.wallpaper === filePath

                width: 200
                height: 120
                radius: 14
                lift: chosen ? 2 : 5
                fill: Theme.surfaceHigh
                onClicked: page.pick(filePath)

                Image {
                    anchors.fill: parent
                    anchors.margins: 4
                    source: "file://" + thumb.filePath
                    sourceSize: Qt.size(256, 160)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: "transparent"
                    border.color: thumb.chosen ? Theme.star : "transparent"
                    border.width: 3
                }
            }
        }
    }
}
