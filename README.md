# noctalia-plugins

> ⚠️ Much of the code for these plugins was created using Claude Code (Sonnet 5). Each one is designed to solve a specific problem with my system, but I’m making them publicly available in case they’re useful to anyone else.

Personal plugins for [Noctalia Shell](https://noctalia.dev) (Luau plugin system, `plugin.toml` + `.luau`, v5+), one per folder in the root, same as `official-plugins`/`community-plugins`.

| Plugin | What it does |
| --- | --- |
| [`monitor-profile-switcher`](monitor-profile-switcher/) | Cycles through 3 monitor configurations in Hyprland (native Lua config) from the bar or using keyboard shortcuts. |
| [`dualsense-battery`](dualsense-battery/) | Displays the DualSense (PS5) controller’s battery level in the bar, reading directly from UPower. |

Each plugin has its own README file detailing why it exists, how it works, its requirements and known limitations.

## Adding this repository as a source in Noctalia

As each plugin resides in its own folder in the root directory, Noctalia can read the entire repository as a single source, just as it reads `official-plugins`/`community-plugins`:

```sh
noctalia msg plugins source add jdl-noctalia-plugins git https://github.com/JDLeongomez/noctalia-plugins
noctalia msg plugins enable jdl/monitor-profile-switcher
noctalia msg plugins enable jdl/dualsense-battery
```

Or, for local development without using Git:

```sh
git clone https://github.com/JDLeongomez/noctalia-plugins ~/Documents/GitHub/noctalia-plugins
noctalia msg plugins source add jdl-noctalia-plugins-local path ~/Documents/GitHub/noctalia-plugins
```

`monitor-profile-switcher` also relies on an external script beyond Noctalia’s control (`~/.config/hypr/scripts/monitor-profile.sh`) and a keyboard shortcut in your Hyprland configuration; `./install.sh` automates what it can and provides step-by-step documentation for the rest. `dualsense-battery` doesn’t require any of that; you just need to enable it.

```sh
./install.sh
```
