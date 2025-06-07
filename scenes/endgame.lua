local scene = {}

local pool = {}

local cassette = engine:cassette()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()
local overlay = engine:overlay()
local resourcemanager = engine:resourcemanager()
local fontfactory = engine:fontfactory()

function scene.on_enter()
  local font = fontfactory:get("rpgfont")

  pool.label1 = overlay:create(WidgetType.label)
  pool.label1.font = font
  pool.label1:set("They said that light is the path of the eyes", 14, 3)

  pool.label2 = overlay:create(WidgetType.label)
  pool.label2.font = font
  pool.label2:set("Then darkness comes and erases such a path", 20, 250)

  pool.timers = {}

  timermanager:singleshot(1000, function()
    pool.skull = scene:get("skull", SceneType.object)
    pool.alpha = 0
    pool.skull.alpha = 0
    pool.skull.action = "default"

    local effect = scene:get("skull", SceneType.effect)
    effect:play()

    local direction = 1
    pool.loop = timermanager:set(30, function()
      local dx = math.random(-3, 3)
      local dy = math.random(-3, 3)
      pool.skull.placement = { dx, dy }

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

  for o in pairs(pool) do
    pool[o] = nil
  end
end

return scene
