local scene = {}

local pool = {}

local scenemanager = engine:scenemanager()

function scene.on_enter()
  scenemanager:destroy("*")
  scenemanager:register("babyroom")

  pool.clicks = 0
  pool.click = scene:get("click", SceneType.effect)
end

function scene.on_touch()
  pool.click:play()

  pool.clicks = pool.clicks + 1
  if pool.clicks >= 1 then
    scenemanager:set("babyroom")
  end
end

function scene.on_loop() end

function scene.on_leave()
  for o in pairs(pool) do
    pool[o] = nil
  end
end

return scene
