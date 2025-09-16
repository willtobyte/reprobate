local scene = {}

local pool = {}

local scenemanager = engine:scenemanager()

function scene.on_enter()
  scenemanager:destroy("livingroom")
  scenemanager:register("pearintosh")
end

function scene.on_leave()
  for o in pairs(pool) do
    pool[o] = nil
  end
end

sentinel(scene, "highschool")

return scene
