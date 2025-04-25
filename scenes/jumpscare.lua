local scene = {}

local pool = {}

local cassette = engine:cassette()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()

function scene.on_enter()
  cassette:set("system/stage", "jumpscare")
  -- scenemanager:destroy("babyroom")
  -- resourcemanager:flush()

  pool.timers = {}

  timermanager:singleshot(1000, function ()
    pool.skull = scene:get("skull", SceneType.object)
    pool.alpha = 0
    pool.skull.alpha = 0
    pool.skull.action:set("default")

    local effect = scene:get("skull", SceneType.effect)
    effect:play()

    local direction = 1
    pool.loop = timermanager:set(30, function()
      local dx = math.random(-3, 3)
      local dy = math.random(-3, 3)
      pool.skull.placement:set(dx, dy)

      pool.alpha = pool.alpha + (10 * direction)
      pool.alpha = math.max(0, math.min(pool.alpha, 255))
      pool.skull.alpha = pool.alpha

      if direction == 1 and pool.alpha >= 255 then
        direction = -1
      elseif direction == -1 and pool.alpha <= 0 then
        timermanager:clear(pool.loop)
        pool.loop = nil
      end
      end)
    end)
end

function scene.on_leave()
  for _, id in ipairs(pool.timers) do
    timermanager:clear(id)
  end

  pool.timers = {}

  pool = {}
end

return scene
