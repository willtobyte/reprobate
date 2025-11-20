local scene = {}

local stage = state.system.stage or "babyroom"

local function go()
  pool.music:stop()
  pool.play:on_touch(nil)
  pool.credits:on_touch(nil)

  pool.noise:play(true)
  pool.interference.action = "default"

  local fn = jump.to(stage, 1100)
  fn()
end

function scene.on_enter()
  transition({
    destroy = { "prelude" },
    register = { "whobuilt", stage },
  })

  pool.music = scene:get("theme", SceneKind.effect)
  pool.music:play(true)

  pool.play = scene:get("play", SceneKind.object)
  pool.play:on_touch(go)

  pool.credits = scene:get("credits", SceneKind.object)
  pool.credits:on_touch(jump.to("whobuilt"))

  pool.noise = scene:get("noise", SceneKind.effect)

  pool.interference = scene:get("interference", SceneKind.object)

  pool.headbanger = scene:get("headbanger", SceneKind.object)
end

function scene.on_motion(x, y)
  if x > 240 then -- 480 / 2
    pool.headbanger.action = "right"
  else
    pool.headbanger.action = "left"
  end
end

sentinel(scene, "mainmenu")

return scene
