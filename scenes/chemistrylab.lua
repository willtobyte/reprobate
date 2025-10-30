local scene = {}

local pool = {}

local lantern = require("effects/lantern")

function scene.on_enter()
  pool.dark = cassette:get(key, true)
  if not pool.dark then
    -- Enable clicks
  end
end

function scene.on_motion(x, y)
  if pool.dark then
    lantern:motion(x, y)
  end
end

function scene.on_loop()
  if pool.dark then
    lantern:loop()
  end
end

function scene.on_leave()
  lantern:teardown()

  pool = {}
end

sentinel(scene, "chemistrylab")

return scene
