local scene = {}

local noise = require("effects/noise")
local scribe = require("helpers/scribe")

local pool = {}

local prefix = "babyroom/"

local cassette = engine:cassette()
local overlay = engine:overlay()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()
local soundmanager = engine:soundmanager()

function scene.on_enter()
  noise.init()

  pool.timers = {}

  for _, object in ipairs({
    { name = "car", minimum = 3, maximum = 8, action = "run" },
    { name = "bear", minimum = 2, maximum = 4, action = "blink" },
    { name = "clown", minimum = 6, maximum = 8, action = "blink" },
    { name = "robot", minimum = 3, maximum = 6, action = "shake" },
  }) do
    pool[object.name] = scene:get(object.name)
    local delay = math.random(object.minimum, object.maximum) * 1000
    local id = timermanager:set(delay, function()
      pool[object.name].action:set(object.action)
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
    local key = prefix .. item.name
    pool[item.name] = scene:get(item.name)

    if cassette:get(key, false) then
      pool[item.name]:hide()
    else
      pool[item.name]:on_touch(function()
        if item.damage then
          overlay:dispatch(Widget.cursor, "damage")
        end

        if item.sound then
          soundmanager:play(item.sound)
        end

        pool.television.action:set("poltergeist")
        pool[item.name]:hide()
        cassette:set(key, true)
      end)
    end
  end

  pool.beelzebuuth = scene:get("beelzebuuth")

  noise.on_finish(function()
    scribe.write("I drown your holiness in the Acheron of my soul", 3, 3)
    scribe.on_finish(12000, scribe.clear)
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
  if pool.lock then
    return
  end

  pool.touches = (pool.touches or 0) + 1
  pool.threshold = pool.threshold or math.random(3, 6)
  if pool.touches < pool.threshold then
    return
  end

  pool.touches = 0
  pool.threshold = math.random(3, 6)

  local hints = {
    crucifix = "His sacrifice means nothing",
    gijoe    = "Covert missions demand unbreakable resolve",
    nintendo = "Joy fades leaving glitching code",
    playboy  = "Velvet whispers ignite hidden passions",
  }

  local candidates = {}
  for name, _ in pairs(hints) do
    if not cassette:get(prefix .. name, false) then
      table.insert(candidates, name)
    end
  end

  local want = math.random() < 0.5
  local can = #candidates > 0
  if want and can then
    local chosen = candidates[math.random(#candidates)]

    pool.lock = true
    scribe.clear()
    scribe.write(hints[chosen], 3, 3)
    scribe.on_finish(3000, function()
      scribe.clear()
      pool.lock = false
    end)
    return
  end

  pool.beelzebuuth.action:set("summon")
  soundmanager:play("scream")
end

return scene
