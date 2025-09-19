local scene = {}

local pool = setmetatable({ timers = {} }, { __mode = "k" })

local scenemanager = engine:scenemanager()

function scene.on_enter()
  scenemanager:destroy("mainmenu")
  scenemanager:destroy("whobuilt")
  scenemanager:destroy("livingroom")
  scenemanager:register("pearintosh")

  cassette:set("system/stage", "highschool")

  --
end

function scene.on_leave()
  for _, id in ipairs(pool.timers) do
    timermanager:clear(id)
  end

  for name in pairs(pool) do
    pool[name] = nil
  end
end

sentinel(scene, "highschool")

return scene
