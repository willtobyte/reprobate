local scene = {}

local pool = {}

function scene.on_enter()
  pool.lightmask = scene:get("lightmask", SceneType.object)
end

function scene.on_motion(x, y)
  pool.lightmask.placement = { x - 588, y - 331 }
end

function scene.on_loop()
  print(mouse.x)
  print(mouse.y)

  local x, y = mouse.xy()

  print(x, y)
  print(mouse.button)
end

function scene.on_leave()
  pool = {}
end

sentinel(scene, "chemistrylab")

return scene
