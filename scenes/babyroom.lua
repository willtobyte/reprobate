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

  for _, o in ipairs({
    { name = "car", minimum = 3, maximum = 8, action = "run" },
    { name = "bear", minimum = 2, maximum = 4, action = "blink" },
    { name = "clown", minimum = 6, maximum = 8, action = "blink" },
    { name = "robot", minimum = 3, maximum = 6, action = "shake" },
  }) do
    pool[o.name] = scene:get(o.name)
    local delay = math.random(o.minimum, o.maximum) * 1000
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
  if math.random() > 0.3 then return end

  scribe.clear()

  local hints = {
    crucifix = "The sacred burns when held by the unworthy",
    gijoe = "Plastic warriors fall silent in cursed halls",
    nintendo = "Joy bleeds through rusted circuits",
    playboy = "Desire decays beneath forgotten pages",
  }

  local candidates = {}

  for name, _ in pairs(hints) do
    local key = prefix .. name
    if not cassette:get(key, false) then
      table.insert(candidates, name)
    end
  end

  if #candidates == 0 then return end

  local chosen = candidates[math.random(#candidates)]
  scribe.write(hints[chosen], 3, 3)
  scribe.on_finish(6000, scribe.clear)
end

return scene
