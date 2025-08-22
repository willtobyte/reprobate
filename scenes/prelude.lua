local scene = {}

local pool = {}

local scenemanager = engine:scenemanager()

local nextscene = "mainmenu"

function scene.on_enter()
  scenemanager:register(nextscene)

  pool.clicks = 0
  pool.click = scene:get("click", SceneType.effect)
end

function scene.on_touch()
  pool.click:play()

  pool.clicks = pool.clicks + 1
  if pool.clicks >= 3 then
    scenemanager:set(nextscene)
  end
end

function scene.on_loop() end

function scene.on_leave()
  for o in pairs(pool) do
    pool[o] = nil
  end
end

return scene
