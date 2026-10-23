import QtQuick
import QtQuick.Layouts
import Twilight.Core
import "../parts"

// The plugins that were found, each with a switch, and the folders they are
// looked for in. Both are kept in plugins.toml, which the plugins module reads.
Page {
    id: page

    // Where plugins.defaults.toml is, so what plugins.toml lacks reads its defaults.
    property url defaults
    // [{ name, title, version, description, author, enabled, error }], from the
    // plugins module. The host sets it.
    property var plugins: []

    readonly property var enabled: config.get("enabled") ?? []
    readonly property var dirs: config.get("dirs") ?? []

    title: "Plugins"
    subtitle: "Extra things for the shell, each one a folder with a plugin.toml. A plugin is code that runs with your rights, so only switch on the ones you trust."

    ConfigFile {
        id: config

        name: "plugins"
        defaults: page.defaults
    }

    function setEnabled(name: string, on: bool): void {
        const rest = enabled.filter(n => n !== name);
        config.set("enabled", on ? [...rest, name] : rest);
    }

    Option {
        title: "Folders"
        description: "Where plugins are looked for, each folder holding one folder per plugin. Separate them with spaces. Enter saves."

        Field {
            implicitWidth: 340
            value: page.dirs.join(" ")
            onCommitted: value => config.set("dirs", value.split(/\s+/).filter(w => w !== ""))
        }
    }

    StyledText {
        Layout.fillWidth: true
        Layout.topMargin: 6
        text: "FOUND"
        color: Theme.muted
        font.pixelSize: 11
        font.letterSpacing: 1
    }

    StyledText {
        Layout.fillWidth: true
        visible: page.plugins.length === 0
        text: "✧ No plugins yet. Put a folder with a plugin.toml into " + (page.dirs[0] ?? "a plugin folder") + " and it shows up here. The plugin template is a place to start."
        color: Theme.muted
        font.pixelSize: 12
        wrapMode: Text.Wrap
    }

    Repeater {
        model: page.plugins

        Option {
            id: row

            required property var modelData

            title: modelData.title + (modelData.version !== "" ? "  " + modelData.version : "")
            description: [modelData.description, modelData.author !== "" ? "by " + modelData.author : ""].filter(t => t !== "").join(" · ")
            note: modelData.error

            Toggle {
                checked: page.enabled.includes(row.modelData.name)
                onToggled: checked => page.setEnabled(row.modelData.name, checked)
            }
        }
    }
}
