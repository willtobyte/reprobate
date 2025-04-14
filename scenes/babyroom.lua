local noise = require("effects/noise")
local writter = require("helpers/writter")

local scene = {}
local pool = {}

local cassette = engine:cassette()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()
local soundmanager = engine:soundmanager()

function scene.on_enter()
  noise.init()

  pool.timers = {}

  for _, o in ipairs({
    { name = "car", min = 3, max = 8, action = "run" },
    { name = "bear", min = 2, max = 4, action = "blink" },
    { name = "clown", min = 6, max = 8, action = "blink" },
    { name = "robot", min = 3, max = 6, action = "shake" },
  }) do
    pool[o.name] = scene:get(o.name)
    local delay = math.random(o.min, o.max) * 1000
    local id = timermanager:set(delay, function()
      pool[o.name].action:set(o.action)
    end)
    table.insert(pool.timers, id)
  end

  pool.television = scene:get("television")

  for _, item in ipairs({
    { name = "crucifix", sound = "wind", damage = true },
    { name = "gijoe", sound = "door" },
    { name = "nintendo", sound = "metal" },
    { name = "playboy", sound = "gore" },
  }) do
    local key = "babyroom/" .. item.name
    pool[item.name] = scene:get(item.name)

    if cassette:get(key, false) then
      pool[item.name]:hide()
    else
      pool[item.name]:on_touch(function()
        if item.damage then overlay:dispatch(Widget.cursor, "damage") end
        if item.sound then soundmanager:play(item.sound) end
        pool.television.action:set("poltergeist")
        pool[item.name]:hide()
        cassette:set(key, true)
      end)
    end
  end

  pool.beelzebuuth = scene:get("beelzebuuth")

  -- Uncomment to enable the beelzebuuth summon event after 6.66*6000ms
  -- local id = timermanager:set(6.66 * 6000, function()
  --   soundmanager:play("scream")
  --   pool.beelzebuuth.action:set("summon")
  -- end)
  -- table.insert(pool.timers, id)

  noise.on_end(function()
    writter.write("I drown your holiness in the Acheron of my soul", 3, 3)
  end)
end

function scene.on_loop()
  noise.loop()
end

function scene.on_leave()
  noise.teardown()
  for _, id in ipairs(pool.timers) do
    timermanager:clear(id)
  end
  for k in pairs(pool) do
    pool[k] = nil
  end
end

function scene.on_touch()
  pool.label:clear()
  if pool.timer then
    timermanager:clear(pool.timer)
    pool.timer = nil
  end
end

return scene
