local scene = {}

local pool = {}

local scenemanager = engine:scenemanager()

function scene.on_enter()
  scenemanager:destroy("*")
end

function scene.on_leave()
  for o in pairs(pool) do
    pool[o] = nil
  end
end

return scene
