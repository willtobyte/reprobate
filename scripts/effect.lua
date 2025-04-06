local effect = {}

local canvas = engine:canvas()

local w, h = 480, 270
local pixels = {}
local start = nil
local duration = 1200

function effect.init()
  start = ticks()
end

function effect.loop()
  local elapsed = ticks() - start
  local alpha

  if elapsed < duration then
    alpha = math.floor(255 * (1 - elapsed / duration))
  else
    alpha = 0
  end

  if alpha == 0 then
    return
  end

  for y = 0, h - 1 do
    local base = y * w
    for x = 0, w - 1 do
      local intensity = math.random(0, 255)
      if y % 2 == 0 then
        intensity = math.floor(intensity * 0.7)
      end
      pixels[base + x + 1] = alpha * 0x01000000 + intensity * 0x010101
    end
  end

  canvas.pixels = pixels
end

function effect.teardown()
end

return effect
