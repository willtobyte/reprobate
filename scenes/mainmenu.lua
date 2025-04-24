local scene = {}

local cassette = engine:cassette()

local scenemanager = engine:scenemanager()

local pool = {}

function scene.on_enter()
  local play = scene:get("play", SceneType.object)
  play:on_touch(function ()
    local stage = cassette:get("system/stage", "babyroom")

    scenemanager:set(stage)
  end)

  local credits = scene:get("credits", SceneType.object)
  credits:on_touch(function ()
    openurl("https://rodrigodelduca.org")
  end)

  pool.headbanger = scene:get("headbanger", SceneType.object)
end

function scene.on_leave()
  pool = {}
end

function scene.on_motion(x, y)
  print("x " .. tostring(x) .. " y " .. tostring(y))
  if x > 240 then -- 480 / 2
    pool.headbanger.action:set("right")
  else
    pool.headbanger.action:set("left")
  end
end

return scene
