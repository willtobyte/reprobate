local scene = {}

local scenemanager = engine:scenemanager()

local pool = {}

function scene.on_enter()
  local play = scene:get("play")
  play:on_touch(function ()
    scenemanager:set("babyroom")
  end)

  pool.headbanger = scene:get("headbanger")
end

function scene.on_motion(x, y)
  if x > 240 then -- 480 / 2
    pool.headbanger.action:set("right")
  else
    pool.headbanger.action:set("left")
  end
end

return scene
