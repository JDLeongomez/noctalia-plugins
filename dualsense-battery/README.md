# dualsense-battery

> ⚠️ Much of this plugin's code was created using Claude Code (Sonnet 5).

Displays the battery level of the DualSense controller (PS5) in the [Noctalia](https://noctalia.dev) bar, reading directly from UPower via D-Bus.

## Why it exists

There is no official or community-developed Noctalia plugin for this. The only external plugin found (`sukar0972/dualsense-qml`) is designed for the QML architecture of the shell prior to Noctalia v5, which is incompatible with the current Luau plugin system (`plugin.toml` + `.luau`).

The obvious alternative would be to wrap `dualsensectl`, as other control plugins do (lightbar, haptic triggers, etc.), but this is unnecessary if you’re just displaying the battery level: the kernel driver (`hid-playstation`) already exposes the DualSense’s battery as a standard `power_supply` device as soon as it’s connected via Bluetooth, and UPower picks it up automatically. Check this by running:

```sh
upower -d | grep -A10 -i dualsense
```

If the device appears there, this plugin doesn’t need to run any external processes; it simply asks UPower for the information it already knows, just as the official `yocraft/battery-widget` plugin does for the laptop’s battery.

## How it works

- `service.luau` enumerates UPower devices via D-Bus (`gdbus call ... EnumerateDevices`) and looks for one whose path contains `controller_battery`; rather than specifying the path by MAC address, this ensures it continues to work if you re-pair the controller. Once found, it reads `Percentage`/`State` every 60 seconds. 
- If a read operation fails on a known path (for example, because UPower has removed and will recreate the object), it forgets that path and re-enumerates on the next cycle, rather than persisting indefinitely with an invalid path.
- `widget.luau` displays a control icon (`device-gamepad-2`, not a generic battery icon) with the percentage next to it, and a lightning bolt glyph (Nerd Font, not an emoji, so that it matches the theme colour) whilst it is charging.

## Requirements

- `gdbus` in the `PATH` (part of `glib2`, almost always already installed).
- UPower running and detecting the controller (see above). It usually works via Bluetooth only; via USB, it varies depending on the kernel.
- Noctalia v5+ (Luau plugin system).

## Installation

Clone the entire repository (see the root README), add it as a source in Noctalia, enable `jdl/dualsense-battery`, and add the ‘DualSense Battery’ widget to the status bar.

## Known limitation: delays after reconnecting

If the controller has been switched off or inactive for a while, the time it takes for the icon to appear can vary considerably (from a few seconds to around 30 minutes in extreme cases). This is not a problem with this plugin: it is BlueZ’s standard behaviour with HID peripherals. Following a disconnection, the host (`bluetoothd`) retries the connection once or twice and, if this fails, stops trying and waits passively for the controller itself to initiate reconnection (typically by pressing a button). The plugin can only read what UPower already knows, so it inherits that delay.

Diagnosis confirmed by checking `journalctl -b -u bluetooth`: two failed attempts (“Host is down”) followed by complete silence until the kernel registers the controller again, minutes later, without any retries from the PC’s side.
