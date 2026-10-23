import QtQuick
import Quickshell
import Quickshell.Io
import Twilight.Core

// The settings the installed components describe. A component ships
// <name>.schema.toml next to its <name>.defaults.toml; this finds those files
// in the module directories Qt searches and parses them into `pages`:
//
//     title = "Bar"
//     description = "What the islands at the top of the screen show."
//     glyph = "▬"
//     order = 40
//
//     [[options]]
//     key = "clock.seconds"
//     title = "Seconds"
//     description = "Show seconds in the clock."
//     type = "toggle"            # or "range" (from, to, step, suffix, decimals)
//                                # or "choice" (choices = [{ value = 0, label = "never" }])
Scope {
    id: root

    // [{ name, title, description, glyph, order, defaults, options }], in order.
    property var pages: []
    // The defaults file of every component that has one, by the name of its
    // settings file: { bar: "file:///.../bar.defaults.toml" }. For the pages
    // that are drawn by hand and so have no schema.
    property var defaults: ({})

    // Where to look: the directories on QML_IMPORT_PATH, and the one the
    // modules are installed in, which is where this module is too.
    readonly property var roots: {
        const dirs = (Quickshell.env("QML_IMPORT_PATH") ?? "").split(":").filter(d => d !== "");
        dirs.push(Qt.resolvedUrl("../..").toString().replace(/^file:\/\//, "").replace(/\/$/, ""));
        return dirs;
    }

    function parse(chunk: string): var {
        const nl = chunk.indexOf("\n");
        const path = chunk.slice(0, nl);
        try {
            const schema = Toml.parse(chunk.slice(nl + 1));
            const dir = path.slice(0, path.lastIndexOf("/"));
            const name = path.slice(path.lastIndexOf("/") + 1).replace(/\.schema\.toml$/, "");
            return {
                name: name,
                title: schema.title ?? name,
                description: schema.description ?? "",
                glyph: schema.glyph ?? "✦",
                order: schema.order ?? 100,
                defaults: "file://" + dir + "/" + name + ".defaults.toml",
                options: schema.options ?? []
            };
        } catch (e) {
            console.warn("twilight: " + path + ": " + e.message);
            return null;
        }
    }

    Process {
        command: ["sh", "-c", "find -L \"$@\" -maxdepth 4 \\( -name '*.schema.toml' -o -name '*.defaults.toml' \\) -exec sh -c 'for f; do printf \"@@@%s\\n\" \"$f\"; case \"$f\" in *.schema.toml) cat \"$f\";; esac; done' _ {} +", "_"].concat(root.roots)
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const seen = [];
                const found = [];
                const defaults = {};
                for (const chunk of text.split("@@@").filter(c => c.trim() !== "")) {
                    const path = chunk.split("\n")[0];
                    if (path.endsWith(".defaults.toml")) {
                        const name = path.slice(path.lastIndexOf("/") + 1).replace(/\.defaults\.toml$/, "");
                        if (!(name in defaults))
                            defaults[name] = "file://" + path;
                        continue;
                    }
                    const page = root.parse(chunk);
                    // The same component can be found twice: the first one wins.
                    if (page && !seen.includes(page.name)) {
                        seen.push(page.name);
                        found.push(page);
                    }
                }
                found.sort((a, b) => a.order - b.order || a.title.localeCompare(b.title));
                root.pages = found;
                root.defaults = defaults;
            }
        }
    }
}
