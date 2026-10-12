#!/usr/bin/env bash
# Register this repository as a plugin source in Noctalia and, for
# monitor-profile-switcher, copy its external script to ~/.config/hypr/scripts/.
# It does not automatically modify binds.lua: this must be added manually (see
# monitor-profile-switcher/README.md).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.config/hypr/scripts"
cp "$REPO_DIR/monitor-profile-switcher/hypr/monitor-profile.sh" "$HOME/.config/hypr/scripts/monitor-profile.sh"
chmod +x "$HOME/.config/hypr/scripts/monitor-profile.sh"
echo "-> Copied to $HOME/.config/hypr/scripts/monitor-profile.sh"

if command -v noctalia >/dev/null 2>&1; then
    noctalia msg plugins source add jdl-noctalia-plugins path "$REPO_DIR"
    noctalia msg plugins enable jdl/monitor-profile-switcher
    noctalia msg plugins enable jdl/dualsense-battery
    echo "-> Noctalia plugins enabled (jdl/monitor-profile-switcher, jdl/dualsense-battery)"
else
    echo "-> Noctalia is not in the PATH; I have skipped registering the plugins. Do this manually:"
    echo "     noctalia msg plugins source add jdl-noctalia-plugins path '$REPO_DIR'"
    echo "     noctalia msg plugins enable jdl/monitor-profile-switcher"
    echo "     noctalia msg plugins enable jdl/dualsense-battery"
fi

cat <<EOF

Remaining steps (manual; these depend on your configuration and hardware):

monitor-profile-switcher:
  1. Check your actual outputs using: hyprctl monitors
     Edit MON1/MON2/MON3 at the start of
     $HOME/.config/hypr/scripts/monitor-profile.sh if they do not match
     DP-2 / DP-3 / HDMI-A-1.
  2. Copy the contents of monitor-profile-switcher/hypr/binds-snippet.lua
     into your config/binds.lua (or the keybinds file in your
     Hyprland configuration), and then: hyprctl reload
  3. In Noctalia: Settings -> Bar -> add the widget
     "Monitor Profile Switcher -> toggle" to the section of your choice.

dualsense-battery:
  - Check that UPower detects the controller:
      upower -d | grep -A10 -i dualsense
  - In Noctalia: Settings -> Bar -> add the "DualSense Battery" widget.

Details of each plugin can be found in its own README.
EOF
