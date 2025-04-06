local effect = {}

local canvas = engine:canvas()

local w, h = 480, 270
local pixels = {}

function effect.on_enter()
end

function effect.on_loop()
  for y = 0, h - 1 do
    local base = y * w
    for x = 0, w - 1 do
      local intensity = math.random(0, 255)

      if y % 2 == 0 then
        intensity = math.floor(intensity * 0.7)
      end

      pixels[base + x + 1] = 0xFF000000 + intensity * 0x010101
    end
  end

  canvas.pixels = pixels
end

function effect.on_leave()
end

return effect
