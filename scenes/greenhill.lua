local camera = require("camera")

local scene = {}

function scene.on_enter() end

function scene.on_camera(delta)
  return camera.calculate(delta)
end

sentinel(scene, "greenhill")

return scene
