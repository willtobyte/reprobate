local scene = {}

local pool = setmetatable({}, { __mode = "k" })

local scenemanager = engine:scenemanager()

function scene.on_enter()
  scenemanager:register("mainmenu")
  scenemanager:register("whobuilt")

  pool.quarter = scene:get("quarter", SceneType.object)

  pool.quarter:on_hover(function(self)
    self.action = "hover"
  end)

  pool.quarter:on_unhover(function(self)
    self.action = "normal"
  end)

  pool.quarter:on_touch(function()
    scenemanager:set("mainmenu")
  end)

  pool.click = scene:get("click", SceneType.effect)
end

function scene.on_touch()
  pool.click:play()
end

function scene.on_leave()
  for name in pairs(pool) do
    pool[name] = nil
  end
end

sentinel(scene, "prelude")

return scene
