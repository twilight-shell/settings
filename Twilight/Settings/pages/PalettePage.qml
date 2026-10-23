import QtQuick
import QtQuick.Layouts
import Twilight.Core
import "../parts"

// The palette the shell is painted with: the ones that come with it, the colors
// of the wallpaper, and the palettes you make yourself.
Page {
    id: page

    title: "Appearance"
    subtitle: "The palette every part of the shell is painted with."

    // theme.toml, where the palette and your own palettes are written.
    ConfigFile {
        id: theme

        name: "theme"
    }

    readonly property string current: Theme.paletteName
    readonly property var custom: Theme.customPalettes
    readonly property var entries: [
        { key: "wallpaper", name: "Wallpaper", colors: null },
        { key: "twilight", name: "Twilight", colors: Theme.twilight },
        ...Object.keys(Palette.presets).map(k => ({ key: k, name: Palette.presets[k].name, colors: Palette.fromPreset(Palette.presets[k]) })),
        ...Object.keys(custom).map(k => ({ key: k, name: custom[k].name ?? k, colors: Palette.fromCustom(custom[k]) }))
    ]

    function choose(key: string): void {
        theme.set("palette", key);
    }

    // A new scheme starts as Twilight's, and is chosen so its colors show as they are edited.
    function create(): void {
        let id = "custom";
        for (let n = 2; id in custom; n++)
            id = "custom-" + n;
        const t = Theme.twilight;
        theme.set(["palettes", id, "name"], "My scheme");
        theme.set(["palettes", id, "base"], String(t.surface));
        theme.set(["palettes", id, "primary"], String(t.primary));
        theme.set(["palettes", id, "accent"], String(t.accent));
        theme.set(["palettes", id, "secondary"], String(t.secondary));
        choose(id);
    }

    StyledText {
        Layout.fillWidth: true
        text: "PALETTE"
        color: Theme.muted
        font.pixelSize: 11
        font.letterSpacing: 1
    }

    Flow {
        Layout.fillWidth: true
        spacing: 12

        Repeater {
            model: page.entries

            PaletteCard {
                required property var modelData

                colors: modelData.colors
                name: modelData.name
                chosen: page.current === modelData.key
                onClicked: page.choose(modelData.key)
            }
        }

        Tap {
            width: 150
            height: 96
            radius: 16
            lift: 4
            fill: Theme.bg
            hoverFill: Theme.surface
            onClicked: page.create()

            Column {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "✦"
                    color: Theme.star
                    font.pixelSize: 26
                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "New scheme"
                    color: Theme.muted
                    font.pixelSize: 13
                }
            }
        }
    }

    StyledText {
        Layout.fillWidth: true
        visible: Theme.paletteName === "wallpaper" && Theme.liveWallpaper
        text: "✧ The live wallpaper is painted with the palette, so it can't lend one: Twilight's is used meanwhile."
        color: Theme.muted
        font.pixelSize: 11
        wrapMode: Text.Wrap
    }

    StyledText {
        Layout.fillWidth: true
        Layout.topMargin: 6
        visible: page.current in page.custom
        text: "YOUR SCHEME"
        color: Theme.muted
        font.pixelSize: 11
        font.letterSpacing: 1
    }

    Loader {
        Layout.fillWidth: true
        active: page.current in page.custom
        visible: active

        sourceComponent: SchemeEditor {
            schemeId: page.current
            spec: page.custom[page.current]
            config: theme
            // Twilight's palette takes over, so the palette in use exists.
            onRemoved: {
                page.choose("twilight");
                theme.remove(["palettes", schemeId]);
            }
        }
    }
}
