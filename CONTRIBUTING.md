# Contributing to settings

Thank you for helping. The guide for every repository of the organization is [here](https://github.com/twilight-shell/.github/blob/main/CONTRIBUTING.md): how to propose a change, the commit messages, the checks and the code style. What follows is what is particular to this repository.

## Working on it

- **What it needs:** Twilight.Core. Clone them next to this one and put their parent folders on `QML_IMPORT_PATH`, separated by `:`, as full paths (not `~`).
- **Run it:** `XDG_CONFIG_HOME=$(mktemp -d) QML_IMPORT_PATH=$HOME/src/core:$HOME/src/settings qs -p .` (the first part keeps your real settings out of it). Open it with `qs -p . ipc call settings toggle` (or `open <tab>`); it finds schemas on `QML_IMPORT_PATH`, so put the components you want pages for on it.
- **Tests:** there is no test for the screen: run it and look, and say in the pull request what you tried and on which compositor.
- **Before sending:** run the checks of the guide (`ci/run-tests.sh`, `check-settings.sh`, `check-depends.sh`, `check-install.sh` from the `.github` repository) and add a line to `CHANGELOG.md` under `## Unreleased`.

## Good to know

- A schema is `[[options]]` with `key`, `title`, `type` (`toggle`, `range`, `choice`, `text`, `command`); the format is in the README. Keep the window free of component names; a hand-drawn page is for what a schema can't say.
- `Plugins` and `settings` don't import each other; the host hands the window `plugins` and `pluginDirs`.

For security problems, please don't open an issue: see [SECURITY.md](https://github.com/twilight-shell/.github/blob/main/SECURITY.md).
