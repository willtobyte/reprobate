local scene = {}

local pool = {}

local jump = require("helpers/jump")

function scene.on_enter()
  local stage = state.system.stage or "babyroom"

  transition({
    destroy = { "prelude" },
    register = { "whobuilt", stage },
  })

  pool.music = scene:get("theme", SceneType.effect)
  pool.music:play(true)

  pool.play = scene:get("play", SceneType.object)
  pool.play:on_touch(jump.to(stage))

  pool.credits = scene:get("credits", SceneType.object)
  pool.credits:on_touch(jump.to("whobuilt"))

  pool.headbanger = scene:get("headbanger", SceneType.object)
end

function scene.on_motion(x, y)
  if x > 240 then -- 480 / 2
    pool.headbanger.action = "right"
  else
    pool.headbanger.action = "left"
  end
end

function scene.on_leave()
  pool = {}
end

sentinel(scene, "mainmenu")

return scene
