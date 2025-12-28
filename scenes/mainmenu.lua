local scene = {}

local stage = state.system.stage or "babyroom"

local function go()
  pool.theme:stop()

  pool.play:on_touch(nil)
  pool.credits:on_touch(nil)

  pool.noise:play(true)
  pool.interference.action = "default"

  local func = jump.to(stage, 1100)
  func()
end

function scene.on_enter()
  transition({
    destroy = { "prelude" },
    register = { "whobuilt", stage },
  })

  pool.theme:play(true)
  pool.play:on_touch(go)
  pool.credits:on_touch(jump.to("whobuilt"))
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
