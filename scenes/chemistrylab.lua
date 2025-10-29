local scene = {}

local pool = {}

local lantern = require("effects/lantern")

function scene.on_enter() end

function scene.on_motion(x, y)
  -- pool.lightmask.placement = { x - 588, y - 331 }
  lantern:motion(x, y)
end

function scene.on_loop()
  lantern:loop()
end

function scene.on_leave()
  lantern:teardown()

  pool = {}
end

sentinel(scene, "chemistrylab")

return scene
