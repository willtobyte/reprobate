local scene = {}

local pool = {}

local scenemanager = engine:scenemanager()

local next = "mainmenu"

function scene.on_enter()
  scenemanager:register(next)

  pool.single = scene:get("single", SceneType.object)

  pool.single:on_hover(function(self)
    self.action = "hover"
  end)

  pool.single:on_unhover(function(self)
    self.action = "normal"
  end)

  pool.single:on_touch(function()
    scenemanager:set(next)
  end)

  pool.clicks = 0
  pool.click = scene:get("click", SceneType.effect)
end

function scene.on_touch()
  pool.click:play()
end

function scene.on_loop() end

function scene.on_leave()
  for o in pairs(pool) do
    pool[o] = nil
  end
end

return scene
