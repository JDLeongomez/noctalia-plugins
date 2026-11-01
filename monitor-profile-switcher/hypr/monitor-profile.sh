#!/usr/bin/env bash
# Usage: monitor-profile.sh {dual|extended|mirror}
#
# Rewrites config/monitors.lua with the MONITOR3 block for the chosen profile
# and reloads with `hyprctl reload`. The file is rewritten (instead of applying
# the change only live with `hyprctl eval`) because any later reload (manual or
# triggered by something else, e.g. a wallpaper/theme change) reads this file
# from scratch and would discard changes made only in memory, always falling
# back to the profile declared in the file. This way the active profile
# persists across reloads.
set -euo pipefail

MONITORS_LUA="$HOME/.config/hypr/config/monitors.lua"

case "${1:-}" in
  dual)
    MON3_ACTIVE=false
    MON3_BLOCK='hl.monitor({
    output    = MONITOR3,
    disabled  = true,
    mirror    = "",
})'
    ;;
  extended)
    MON3_ACTIVE=true
    MON3_BLOCK='hl.monitor({
    output    = MONITOR3,
    mode      = "1920x1080@60",
    position  = "1920x-1080",
    scale     = "1",
    disabled  = false,
    mirror    = "",
})'
    ;;
  mirror)
    MON3_ACTIVE=false
    MON3_BLOCK='hl.monitor({
    output    = MONITOR3,
    mode      = "1920x1080@60",
    position  = "0x0",
    scale     = "1",
    disabled  = false,
    mirror    = MONITOR2,
})'
    ;;
  *)
    echo "Usage: $0 {dual|extended|mirror}" >&2
    exit 1
    ;;
esac

cat > "$MONITORS_LUA" <<EOF
-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Example: output can be found with hyprctl monitors. Edit variables.lua for the monitor outputs instead of here directly
-- hl.monitor({
--     output    = "MONITOR1",
--     mode      = "1920x1080@60",
--     position  = "0x0",
--     scale     = "1",
-- })

hl.monitor({
    output    = MONITOR1,
    mode      = "preferred",
    position  = "0x0",
    scale     = "auto",
})

hl.monitor({
    output    = MONITOR2,
    mode      = "preferred",
    position  = "1920x0",
    scale     = "auto",
})

-- Active profile: ${1}. Change it with scripts/monitor-profile.sh {dual|extended|mirror}
$MON3_BLOCK

-- Read by config/workspaces.lua: workspace 3 only exists when MONITOR3 is extended
MONITOR3_ACTIVE = $MON3_ACTIVE
EOF

hyprctl reload
