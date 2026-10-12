--!nonstrict

local GLYPH = "device-gamepad-2"
local BOLT = "\u{f0e7}" -- Nerd Font fa-bolt, monochrome (unlike the emoji, respects setColor)

local function render(data)
  data = data or {}

  if not data.present then
    barWidget.setGlyph(GLYPH)
    barWidget.setText("--")
    barWidget.setTooltip({
      { key = "DualSense", value = "Not detected" },
    })
    return
  end

  local percent = data.percent
  local status = data.status or "unknown"
  local label = percent and (math.floor(percent + 0.5) .. "%") or "..."
  if status == "charging" then
    label = BOLT .. " " .. label
  end

  barWidget.setGlyph(GLYPH)
  barWidget.setText(label)
  barWidget.setTooltip({
    { key = "DualSense", value = percent and (math.floor(percent + 0.5) .. "%") or "Unknown" },
    { key = "Status", value = status },
  })
end

noctalia.state.watch("battery", render)
render(noctalia.state.get("battery"))
