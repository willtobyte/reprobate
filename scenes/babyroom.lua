local scene = {}

local noise = require "effects/noise"
local scribe = require "helpers/scribe"
local touch = require "helpers/touch"
local Inventory = require "overlay/inventory"

local pool = {}
local lock = false
local prefix = "babyroom/"

local cassette = engine:cassette()
local overlay = engine:overlay()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()

local timed = {
  car   = { minimum = 3, maximum = 8, action = "run", message = "Ready, set... zoom like RC!" },
  bear  = { minimum = 2, maximum = 4, action = "blink", message = "Every heart needs a teddy bear to lean on" },
  clown = { minimum = 6, maximum = 8, action = "blink", message = "Cosmic clown's eyes track you" },
  robot = { minimum = 3, maximum = 6, action = "shake", message = "Beep boop, need more input!" },
}

local items = {
  crucifix = { damage = true,  hint = "His sacrifice means nothing" },
  gijoe    = { damage = false, hint = "Covert missions demand unbreakable resolve" },
  nintendo = { damage = false, hint = "Joy fades leaving glitching code" },
  playboy  = { damage = false, hint = "Velvet whispers ignite hidden passions" },
}

function scene.on_enter()
  noise:init()

  pool.timers = {}
  pool.collected = {}

  pool.foggy = scene:get("foggy", SceneType.effect)
  pool.television = scene:get("television", SceneType.object)
  pool.beelzebuuth = scene:get("beelzebuuth", SceneType.object)

  pool.inventory = Inventory.new(scene:get("inventory", SceneType.object))

  pool.television:on_touch(function ()
    scribe:clear()
    scribe:write("This house is haunted-can you feel it?", 3, 3)
    scribe:on_finish(6000, function()
      scribe:clear()
    end)
  end)

  for name, config in pairs(timed) do
    local object = scene:get(name, SceneType.object)

    local delay = math.random(config.minimum, config.maximum) * 1000

    local id = timermanager:set(delay, function()
      object.action:set(config.action)
    end)

    object:on_touch(function ()
      scribe:clear()
      scribe:write(config.message, 3, 3)
      scribe:on_finish(6000, function()
        scribe:clear()
      end)
    end)

    pool[name] = object

    table.insert(pool.timers, id)
  end

  for name, config in pairs(items) do
    local key = prefix .. name
    local object = scene:get(name, SceneType.object)
    pool[name] = object

    local done = cassette:get(key, false)

    pool.collected[name] = done

    if done then
      touch.disappear(object)
    end

    if not done then
      object:on_touch(function(self)
        if config.damage then
          overlay:dispatch(WidgetType.cursor, "damage")
        end

        pool.foggy:play()
        pool.television.action:set("poltergeist")
        pool.collected[name] = true

        cassette:set(key, true)

        touch.disappear(self)

        for _, collected in pairs(pool.collected) do
          if not collected then return end
        end

        cassette:set("system/stage", "endgame")

        timermanager:singleshot(1000, function()
          local effect = scene:get("door", SceneType.effect)
          local door = scene:get("door", SceneType.object)
          door:on_touch(function()
            scribe:clear()
            scenemanager:set("endgame")
          end)

          door.action:set("default")

          timermanager:singleshot(3000, function() effect:play() end)
        end)
      end)
    end
  end

  noise:on_finish(function()
    scribe:write("I drown your divinity in the Acheron of my soul", 3, 3)
    scribe:on_finish(12000, function() scribe:clear() end)
  end)
end

function scene.on_loop(delta)
  noise:loop()
  pool.inventory:update(delta)
end

function scene.on_leave()
  noise:teardown()

  for _, id in ipairs(pool.timers) do
    timermanager:clear(id)
  end

  pool = {}
end

function scene.on_touch()
  if lock then return end

  pool.touches = (pool.touches or 0) + 1

  pool.threshold = pool.threshold or math.random(3, 6)

  if pool.touches < pool.threshold then
    return
  end

  pool.touches = 0

  pool.threshold = math.random(3, 6)

  local candidates = {}

  for name in pairs(items) do
    if not cassette:get(prefix .. name, false) then
      table.insert(candidates, name)
    end
  end

  if math.random() < 0.8 and #candidates > 0 then
    lock = true

    local chosen = candidates[math.random(#candidates)]

    scribe:clear()
    scribe:write(items[chosen].hint, 3, 3)
    scribe:on_finish(3000, function()
      scribe:clear()
      lock = false
    end)
    return
  end

  pool.beelzebuuth.action:set("summon")
  local effect = scene:get("scream", SceneType.effect)
  effect:play()

  lock = true
  timermanager:singleshot(1000, function()
    lock = false
  end)
end

function scene.on_motion(x, y)
  pool.inventory:on_motion(x, y)
end

return scene
