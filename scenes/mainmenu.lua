local scene = {}

local jump = require("helpers/jump")

function scene.on_enter()
  -- local stage = state.system.stage or "babyroom"

  transition({
    destroy = { "prelude" },
    register = { "whobuilt", "retrostatic" },
  })

  pool.music = scene:get("theme", SceneKind.effect)
  pool.music:play(true)

  pool.play = scene:get("play", SceneKind.object)
  pool.play:on_touch(jump.to("retrostatic"))

  pool.credits = scene:get("credits", SceneKind.object)
  pool.credits:on_touch(jump.to("whobuilt"))

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
