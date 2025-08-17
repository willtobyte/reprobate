local effect = require("effects/lantern")

local scene = {}

local pool = {}

function scene.on_enter() end

function scene.on_motion(x, y)
  effect:motion(x, y)
end

function scene.on_loop()
  effect:loop()
end

function scene.on_leave()
  effect:teardown()

  for o in pairs(pool) do
    pool[o] = nil
  end
end

return scene
