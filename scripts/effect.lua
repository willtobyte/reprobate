local effect = {}

local canvas = engine:canvas()

local width, height = 480, 270
local pixels = {}
local start = nil
local duration = 1000

local floor = math.floor
local random = math.random

local MAX_COLOR = 0x010101
local ALPHA_SHIFT = 0x01000000

function effect.init()
  start = ticks()
end

function effect.loop()
  local elapsed = ticks() - start
  local alpha = elapsed < duration and floor(255 * (1 - elapsed / duration)) or 0

  if alpha == 0 then
    return
  end

  local offset = alpha * ALPHA_SHIFT
  local index = 1

  for y = 0, height - 1 do
    local multiplier = (y % 2 == 0) and 0.7 or 1.0

    if multiplier == 1.0 then
      for x = 0, width - 1 do
        pixels[index] = offset + random(0, 255) * MAX_COLOR
        index = index + 1
      end
    else
      for x = 0, width - 1 do
        local intensity = floor(random(0, 255) * multiplier)
        pixels[index] = offset + intensity * MAX_COLOR
        index = index + 1
      end
    end
  end

  canvas.pixels = pixels
end

function effect.teardown()
end

return effect
