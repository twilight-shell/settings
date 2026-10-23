import QtQuick
import QtQuick.Layouts
import Twilight.Core

// A page built from a component's schema: one option per entry, each reading
// and writing the component's own settings file.
Page {
    id: root

    required property var schema

    title: schema.title
    subtitle: schema.description

    ConfigFile {
        id: config

        name: root.schema.name
        defaults: root.schema.defaults
    }

    Repeater {
        model: root.schema.options

        Option {
            id: option

            required property var modelData

            title: modelData.title ?? modelData.key
            description: modelData.description ?? ""

            Loader {
                sourceComponent: ({ toggle: toggle, range: range, choice: choice, text: text, command: command })[option.modelData.type]
            }

            Component {
                id: toggle

                Toggle {
                    checked: !!config.get(option.modelData.key)
                    onToggled: checked => config.set(option.modelData.key, checked)
                }
            }

            Component {
                id: range

                Range {
                    value: Number(config.get(option.modelData.key)) || 0
                    from: option.modelData.from ?? 0
                    to: option.modelData.to ?? 1
                    step: option.modelData.step ?? 1
                    decimals: option.modelData.decimals ?? 0
                    suffix: option.modelData.suffix ?? ""
                    onMoved: v => config.set(option.modelData.key, v)
                }
            }

            Component {
                id: text

                Field {
                    value: String(config.get(option.modelData.key) ?? "")
                    onCommitted: value => config.set(option.modelData.key, value)
                }
            }

            // A command line kept as a list, `ghostty -e` for ["ghostty", "-e"].
            // Words are split at spaces: no quoting.
            Component {
                id: command

                Field {
                    value: (config.get(option.modelData.key) ?? []).join(" ")
                    onCommitted: value => config.set(option.modelData.key, value.split(/\s+/).filter(w => w !== ""))
                }
            }

            Component {
                id: choice

                Choice {
                    options: option.modelData.choices ?? []
                    value: config.get(option.modelData.key)
                    onPicked: value => config.set(option.modelData.key, value)
                }
            }
        }
    }
}
