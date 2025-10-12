local scene = {}

local pool = {}

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

  pool.clicks = 0
end

function scene.on_touch()
  pool.click:play()

  pool.clicks = pool.clicks + 1
  if pool.clicks >= 10 then
    achievement:unlock("ACH_CLICK_FOREHEAD") -- How about trying to click with your forehead?
  end
end

function scene.on_leave()
  for name in next, pool do
    pool[name] = nil
  end
end

sentinel(scene, "prelude")

return scene
