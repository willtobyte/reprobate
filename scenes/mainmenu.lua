local scene = {}

local cassette = engine:cassette()

local scenemanager = engine:scenemanager()

local pool = {}

function scene.on_enter()
  local music = scene:get("theme", SceneType.effect)
  music:play(true)

  local play = scene:get("play", SceneType.object)
  play:on_touch(function()
    local stage = cassette:get("system/stage", "babyroom")

    scenemanager:set(stage)
  end)

  local credits = scene:get("credits", SceneType.object)
  credits:on_touch(function()
    scenemanager:set("whobuilt")
  end)

  pool.headbanger = scene:get("headbanger", SceneType.object)
end

function scene.on_leave()
  for o in pairs(pool) do
    pool[o] = nil
  end
end

function scene.on_motion(x, y)
  if x > 240 then -- 480 / 2
    pool.headbanger.action = "right"
  else
    pool.headbanger.action = "left"
  end
end

return scene
