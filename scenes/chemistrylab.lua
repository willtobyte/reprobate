local scene = {}

local pool = {}

function scene.on_enter()
  pool.lightmask = scene:get("lightmask", SceneType.object)
end

function scene.on_motion(x, y)
  pool.lightmask.placement = { x - 480, y - 322.5 }
end

function scene.on_loop() end

function scene.on_leave()
  pool = {}
end

sentinel(scene, "chemistrylab")

return scene
