-- Add this to your config/binds.lua (Hyprland with native Lua config).
-- Monitor layout profiles (logic in scripts/monitor-profile.sh,
-- shared with the Noctalia plugin)
local monitorProfileScript = "$HOME/.config/hypr/scripts/monitor-profile.sh"
hl.bind(mainMod .. " + CONTROL + ALT + 1", hl.dsp.exec_cmd(monitorProfileScript .. " dual"))
hl.bind(mainMod .. " + CONTROL + ALT + 2", hl.dsp.exec_cmd(monitorProfileScript .. " extended"))
hl.bind(mainMod .. " + CONTROL + ALT + 3", hl.dsp.exec_cmd(monitorProfileScript .. " mirror"))
