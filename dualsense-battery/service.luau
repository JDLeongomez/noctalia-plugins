--!nonstrict
-- Finds the DualSense controller's UPower device dynamically (searches for
-- any "*_controller_battery" device rather than hardcoding the MAC-based
-- object path, so it keeps working if the pad is re-paired) and reads its
-- battery percentage/state over D-Bus, the same backend `upower -d` uses.

local STATE_KEY = "battery"
local devicePath = nil
local lastPercent = nil
local lastStatus = "unknown"

local stateMap = {
  [0] = "unknown",
  [1] = "charging",
  [2] = "discharging",
  [3] = "empty",
  [4] = "fully-charged",
  [5] = "pending-charge",
  [6] = "pending-discharge",
}

noctalia.setUpdateInterval(60000)

local function shellQuote(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function publish(percent, status, present)
  noctalia.state.set(STATE_KEY, { percent = percent, status = status, present = present })
end

local function parseReading(output)
  local percent = output:match("'Percentage':%s*<([%d%.]+)>")
  local state = output:match("'State':%s*<uint32%s+(%d+)>")
  return (percent and tonumber(percent)) or nil, (state and stateMap[tonumber(state)]) or "unknown"
end

local function readDevice()
  local cmd = string.format(
    "gdbus call --system --dest org.freedesktop.UPower --object-path %s --method org.freedesktop.DBus.Properties.GetAll org.freedesktop.UPower.Device",
    shellQuote(devicePath)
  )
  noctalia.runAsync(cmd, function(result)
    if result.exitCode ~= 0 or not result.stdout then
      -- The cached path may no longer be valid (e.g. UPower dropped and will
      -- recreate the device object on reconnect); re-enumerate next tick
      -- instead of retrying a possibly-stale path forever.
      devicePath = nil
      publish(lastPercent, lastStatus, false)
      return
    end
    local percent, status = parseReading(result.stdout)
    if percent then
      lastPercent, lastStatus = percent, status
    end
    publish(lastPercent, lastStatus, true)
  end)
end

local function findDevice()
  noctalia.runAsync(
    "gdbus call --system --dest org.freedesktop.UPower --object-path /org/freedesktop/UPower --method org.freedesktop.UPower.EnumerateDevices",
    function(result)
      if result.exitCode ~= 0 or not result.stdout then
        devicePath = nil
        publish(nil, "unknown", false)
        return
      end
      for path in result.stdout:gmatch("objectpath '([^']+)'") do
        if path:find("controller_battery") then
          devicePath = path
          readDevice()
          return
        end
      end
      devicePath = nil
      publish(nil, "unknown", false)
    end
  )
end

function update()
  if devicePath then
    readDevice()
  else
    findDevice()
  end
end

if not noctalia.commandExists("gdbus") then
  noctalia.log("dualsense-battery: gdbus not found.")
else
  findDevice()
end
