# twilight-shell/settings

[![ci](https://github.com/twilight-shell/settings/actions/workflows/ci.yml/badge.svg)](https://github.com/twilight-shell/settings/actions/workflows/ci.yml)

The settings window of the [twilight-shell](https://github.com/twilight-shell)
organization: tabs on the left, the page on the right, everything applies as it
is changed. It doesn't know the other components: each one describes its own
settings in a schema, and this window builds a page from it. A plugin gets its
page the same way, by shipping a schema.

## Requirements

[Quickshell](https://quickshell.org) 0.3 or newer, with
[twilight-shell/core](https://github.com/twilight-shell/core) installed.

## Running on its own

```sh
qs -p /path/to/settings
qs -p /path/to/settings ipc call settings toggle
qs -p /path/to/settings ipc call settings open bar     # a tab by its name
```

The window looks for schemas in the directories on `QML_IMPORT_PATH` and in the
one the modules are installed in, so point `QML_IMPORT_PATH` at the components
you want pages for, separated by `:`.

## Using it in a shell

```sh
sudo make install        # to /usr/lib/qt6/qml/Twilight/Settings
```

```qml
import Twilight.Settings

Settings { outputName: Compositor.focusedOutput }
```

| | |
|---|---|
| `outputName` | The output to open on; the first screen when empty. The window doesn't know the compositor, so the host says which one. |
| `opened` | Whether it is open; `open(tab)`, `close()` and `toggle()` change it. |

## Describing the settings of a component

Next to its `<name>.defaults.toml` a component puts `<name>.schema.toml`; the
page edits `~/.config/twilight-shell/<name>.toml`.

```toml
title = "Bar"
description = "What the islands at the top of the screen show."
glyph = "▬"             # the tab's symbol
order = 40              # tabs go in this order, then by title

[[options]]
key = "clock.seconds"   # `seconds` in the [clock] table
title = "Seconds"
description = "Show seconds in the clock."
type = "toggle"

[[options]]
key = "chatter"
title = "Chatter"
type = "choice"
choices = [{ value = 0, label = "never" }, { value = 5, label = "5 min" }]

[[options]]
key = "gap"
title = "Gap"
type = "range"
from = 0
to = 40
step = 1
suffix = "px"
```

The types are `toggle`, `range`, `choice`, `text` (a string) and `command` (a
list of words typed with spaces between them, like `ghostty -e`, no quoting).
A text is saved on Enter or when the field loses focus.

The schema holds no values: they and their defaults come from the settings file
and the defaults file.

## Contributing

Contributions are welcome: see [CONTRIBUTING.md](CONTRIBUTING.md). Agents and the like: [AGENTS.md](AGENTS.md).

## License

MIT, see `LICENSE`.
