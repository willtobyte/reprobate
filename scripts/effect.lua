local effect = {}

local canvas = engine:canvas()

local width, height = 480, 270
local pixels = {}
local start = nil
local duration = 1000

local floor = math.floor
local random = math.random

function effect.init()
  start = ticks()
end

function effect.loop()
  local elapsed = ticks() - start
  local alpha = elapsed < duration and floor(255 * (1 - elapsed / duration)) or 0

  if alpha == 0 then
    return
  end

  local offset = alpha * 0x01000000
  local base, intensity, index

  for y = 0, height - 1 do
    base = y * width
    local multiplier = (y % 2 == 0) and 0.7 or 1.0

    for x = 0, width - 1 do
      intensity = random(0, 255)

      if multiplier ~= 1.0 then
        intensity = floor(intensity * multiplier)
      end

      index = base + x + 1
      pixels[index] = offset + intensity * 0x010101
    end
  end

  canvas.pixels = pixels
end

function effect.teardown()
end

return effect