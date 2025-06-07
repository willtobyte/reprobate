local scene = {}

local scenemanager = engine:scenemanager()

local pool = {}

function scene.on_enter()
end

function scene.on_keypress(code)
  scenemanager:set("mainmenu")
end

function scene.on_leave()
  for o in pairs(pool) do
    pool[o] = nil
  end
end

return scene
