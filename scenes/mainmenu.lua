local scene = {}

local pool = {}

local cassette = engine:cassette()

local scenemanager = engine:scenemanager()

function scene.on_enter()
  local stage = cassette:get("system/stage", "babyroom")

  scenemanager:destroy("prelude")
  scenemanager:register("whobuilt")
  scenemanager:register(stage)

  pool.music = scene:get("theme", SceneType.effect)
  pool.music:play(true)

  pool.play = scene:get("play", SceneType.object)
  pool.play:on_touch(function()
    scenemanager:set(stage)
  end)

  pool.credits = scene:get("credits", SceneType.object)
  pool.credits:on_touch(function()
    scenemanager:set("whobuilt")
  end)

  pool.headbanger = scene:get("headbanger", SceneType.object)
end

function scene.on_motion(x, y)
  if not pool.headbanger then
    print(">>> " .. tostring(pool.headbanger))
  end
  end
  if x > 240 then -- 480 / 2
    pool.headbanger.action = "right"
  else
    pool.headbanger.action = "left"
  end
end

function scene.on_leave()
  for name in pairs(pool) do
    pool[name] = nil
  end
end

sentinel(scene, "mainmenu")

return scene
