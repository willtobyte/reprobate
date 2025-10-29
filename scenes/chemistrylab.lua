local scene = {}

local pool = {}

local lantern = require("effects/lantern")

function scene.on_enter() end

function scene.on_motion(x, y)
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
