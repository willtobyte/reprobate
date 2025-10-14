local scene = {}

local pool = {}

function scene.on_enter()
  local stage = cassette:get("system/stage", "babyroom")

  scenemanager:destroy("prelude")
  scenemanager:register("whobuilt")
  scenemanager:register(stage)

  pool.music = scene:get("theme", SceneType.effect)
  pool.music:play(true)

  pool.play = scene:get("play", SceneType.object)
  pool.play:on_touch(function()
    timermanager:singleshot(300, function()
      scenemanager:set(stage)
    end)
  end)

  pool.credits = scene:get("credits", SceneType.object)
  pool.credits:on_touch(function()
    timermanager:singleshot(300, function()
      scenemanager:set("whobuilt")
    end)
  end)

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
  for name in next, pool do
    pool[name] = nil
  end
end

sentinel(scene, "mainmenu")

return scene
