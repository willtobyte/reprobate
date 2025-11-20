local scene = {}

function scene.on_enter()
  transition({ register = { "mainmenu", "whobuilt" } })

  pool.quarter = scene:get("quarter", SceneKind.object)

  pool.quarter:on_hover(function(self)
    self.action = "hover"
  end)

  pool.quarter:on_unhover(function(self)
    self.action = "normal"
  end)

  pool.quarter:on_touch(jump.to("mainmenu"))

  pool.click = scene:get("click", SceneKind.effect)

  pool.clicks = 0
end

function scene.on_touch()
  pool.click:play()

  pool.clicks = pool.clicks + 1
  if pool.clicks >= 10 then
    achievement:unlock("ACH_CLICK_FOREHEAD") -- How about trying to click with your forehead?
  end
end

sentinel(scene, "prelude")

return scene
