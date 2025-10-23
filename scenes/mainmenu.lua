local scene = {}

local pool = {}

local nextscene = require("helpers/nextscene")
local tween = require("library/tween")

function scene.on_enter()
  local stage = cassette:get("system/stage", "babyroom")

  scenemanager:destroy("prelude")
  scenemanager:register("whobuilt")
  scenemanager:register(stage)

  pool.music = scene:get("theme", SceneType.effect)
  pool.music.volume = 0.0
  pool.music:play(true)

  pool.tween = tween.new(5, pool.music, { volume = 1.0 })

  pool.play = scene:get("play", SceneType.object)
  pool.play:on_touch(nextscene.n(stage))

  pool.credits = scene:get("credits", SceneType.object)
  pool.credits:on_touch(nextscene.n("whobuilt"))

  pool.headbanger = scene:get("headbanger", SceneType.object)
end

function scene.on_loop(delta)
  pool.tween:update(delta)
end

function scene.on_motion(x, y)
  if x > 240 then -- 480 / 2
    pool.headbanger.action = "right"
  else
    pool.headbanger.action = "left"
  end
end

function scene.on_leave()
  for key in next, pool do
    pool[key] = nil
  end
end

sentinel(scene, "mainmenu")

return scene
