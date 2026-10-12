# monitor-profile-switcher

> ⚠️ Much of this plugin's code was created using Claude Code (Sonnet 5).
> I created this plugin simply to solve a specific problem with my system, but I'm making it publicly available in case it's useful to someone else.

Switch quickly between 3 monitor configurations in Hyprland (native Lua configuration), using a widget on the [Noctalia](https://noctalia.dev) bar and 3 direct keyboard shortcuts. Originally designed for a 2-monitor + TV setup, but it serves as a template for any combination of fixed outputs.

Included profiles (editable in `hypr/monitor-profile.sh`):

1. **Dual** — monitor1 and monitor2 only; the TV is switched off.
2. **Extended** — all three are active; the TV screen extends beyond monitor2.
3. **Mirror** — the TV screen is mirrored on monitor2.

## Why it exists

There is no official or community-developed Noctalia plugin for this. Two third-party plugins were evaluated, but neither is suitable: one is exclusive to Niri, whilst the other uses a QML plugin architecture that is incompatible with the Luau plugin system (`plugin.toml` + `.luau`) used by Noctalia since version 5. This plugin is a custom implementation, based on that Luau architecture.

## How it works

- `hypr/monitor-profile.sh` rewrites `~/.config/hypr/config/monitors.lua` with the TV block corresponding to the selected profile, and runs `hyprctl reload`. The file is rewritten (rather than applying the change only in real time with `hyprctl eval`) because a subsequent reload – whether manual or triggered by something else (such as a change of wallpaper or theme) – re-reads that file from scratch and would discard any changes made solely in memory. This ensures that the active profile persists between reloads.
- The Noctalia plugin (`plugin.toml` + `service.luau` + `widget.luau`) does not apply the logic itself: `service.luau` polls `hyprctl monitors all -j` every second to detect which profile is actually active (in case it was changed via shortcuts or manually), and calls the same script when the widget is clicked or an IPC event is received. Logic in one place, not duplicated in Lua (Hyprland) and Luau (Noctalia).
- Keyboard shortcuts (`hypr/binds-snippet.lua`) call the script directly, so they work even if the Noctalia bar is down.

Note on Hyprland with native Lua configuration: `hyprctl keyword monitor ...` does not work there (“keyword can’t work with non-legacy parsers”); the equivalent in production is `hyprctl eval` executing `hl.monitor({...})`, the same function used by `monitors.lua`. The script uses this function both for live execution and for what it writes to the file.

## Requirements

- Hyprland with native Lua configuration (in the style of `hl.monitor({...})`, `hl.bind(...)`), **not** the classic `hyprland.conf`.
- Noctalia v5+ (Luau plugin system).
- 3 fixed video outputs, same concept as this setup (2 monitors + 1 TV); if your combination is different, the script serves as a template to be adapted.

## Installation

Clone the entire repository (see the root README) and then:

1. **Copy the script.**
   ```sh
   mkdir -p ~/.config/hypr/scripts
   cp monitor-profile-switcher/hypr/monitor-profile.sh ~/.config/hypr/scripts/
   chmod +x ~/.config/hypr/scripts/monitor-profile.sh
   ```
2. **Edit the outputs.** Find out what yours are using `hyprctl monitors` and adjust `MON1`/`MON2`/`MON3` at the start of `~/.config/hypr/scripts/monitor-profile.sh`.
3. **Add the shortcuts.** Copy the contents of `monitor-profile-switcher/hypr/binds-snippet.lua` into your `config/binds.lua` (or whichever keybinds file you use), and run `hyprctl reload`.
4. **Enable the plugin.** Add the repository as a source in Noctalia (see the root README) and enable `jdl/monitor-profile-switcher`.
5. **Add the widget.** In Noctalia: Settings → Bar → add ‘Monitor Profile Switcher → toggle’ to the section of your choice.

## Usage

- Shortcuts: `SUPER+CONTROL+ALT+1` (dual), `+2` (extended), `+3` (mirror).
- Click the bar widget: cycles through dual → extended → mirror → dual.
- Direct IPC:
  ```sh
  noctalia msg plugin jdl/monitor-profile-switcher:poller all dual
  noctalia msg plugin jdl/monitor-profile-switcher:poller all extended
  noctalia msg plugin jdl/monitor-profile-switcher:poller all mirror
  noctalia msg plugin jdl/monitor-profile-switcher:poller all cycle
  ```
- Directly via the shell: `~/.config/hypr/scripts/monitor-profile.sh {dual|extended|mirror}`.

## Verification

```sh
~/.config/hypr/scripts/monitor-profile.sh dual
hyprctl monitors all -j   # the TV should display "disabled": true
~/.config/hypr/scripts/monitor-profile.sh extended
hyprctl monitors all -j   # "disabled": false, "mirrorOf": "none"
~/.config/hypr/scripts/monitor-profile.sh mirror
hyprctl monitors all -j   # "mirrorOf" points to monitor2
```

`hyprctl monitors` (without `all`) omits disabled outputs; always use `all` to confirm the actual status.

## Known limitations

- The output names (`DP-2`, `DP-3`, `HDMI-A-1`) are hard-coded at the start of `monitor-profile.sh`. On a different machine, with different hardware, you’ll need to edit them manually; this is not a setting that can be changed via the Noctalia UI (making it generalised in this way would only make sense for publication in the community catalogue, which is not the aim of this plugin).
- This requires your Hyprland configuration to use the native Lua style (`hl.monitor`, `hl.bind`); it does not apply to a standard `hyprland.conf` file without adapting the commands.
