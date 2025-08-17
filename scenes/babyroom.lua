local scene = {}

local Inventory = require("overlay/inventory")
local noise = require("effects/noise")
local scribe = require("helpers/scribe")
local visibility = require("helpers/visibility")

local pool = {}
-- local lock = false
local prefix = "babyroom/"

local cassette = engine:cassette()
local overlay = engine:overlay()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()

local animations = {
  car = {
    minimum = 5,
    maximum = 12,
    action = "run",
    message = "Twisted dream. Metal price.",
  },
  bear = {
    minimum = 4,
    maximum = 10,
    action = "blink",
    message = "Do you want to play for five nights at my house?",
  },
  clown = {
    minimum = 6,
    maximum = 18,
    action = "blink",
    message = "A cosmic clown is closing in. Not here for laughs.",
  },
  robot = {
    minimum = 3,
    maximum = 13,
    action = "shrug",
    message = "Need more input!",
  },
}

local items = {
  crucifix = { damage = true, hint = "His sacrifice means nothing." },
  gijoe = { damage = false, hint = "Plastic bones beneath the dust of war." },
  nintendo = { damage = false, hint = "Wires like veins, still twitching." },
  playboy = { damage = false, hint = "Paper temptations sealed behind sin." },
}

function scene.on_enter()
  noise:init()

  scenemanager:destroy("*")
  scenemanager:register("livingroom")

  cassette:set("system/stage", "babyroom")

  pool.missclicks = 0
  pool.timers = {}
  pool.collected = {}

  pool.theme = scene:get("theme", SceneType.effect)
  pool.theme:play(true)

  pool.television = scene:get("television", SceneType.object)
  pool.beelzebuuth = scene:get("beelzebuuth", SceneType.object)

  pool.television:on_touch(function()
    scribe:clear()
    scribe:write("This game is haunted, can you feel it?", 3, 3)
    scribe:on_finish(6000, function()
      scribe:clear()
    end)
  end)

  for name, settings in pairs(animations) do
    local object = scene:get(name, SceneType.object)

    local delay = math.random(settings.minimum, settings.maximum) * 1000

    local id = timermanager:set(delay, function()
      object.action = settings.action
    end)

    table.insert(pool.timers, id)

    object:on_touch(function()
      -- if lock then
      -- 	return
      -- end

      -- lock = true
      scribe:clear()
      scribe:write(settings.message, 3, 3)
      scribe:on_finish(3000, function()
        scribe:clear()
        -- lock = false
      end)
    end)

    pool[name] = object
  end

  local objects = {}
  for name, settings in pairs(items) do
    local key = prefix .. name
    local object = scene:get(name, SceneType.object)
    pool[name] = object

    local iname = "i" .. name
    local inventory = scene:get(iname, SceneType.object)
    pool[iname] = inventory

    table.insert(objects, inventory)

    local done = cassette:get(key, false)

    pool.collected[name] = done

    if done then
      object:hide()
      inventory.action = "default"
    end

    if not done then
      object:on_touch(function(self)
        if settings.damage then
          overlay:dispatch(WidgetType.cursor, "damage")
        end

        pool.television.action = "poltergeist"
        pool.collected[name] = true

        cassette:set(key, true)

        visibility.disappear(self)
        pool[iname].action = "default"

        for _, collected in pairs(pool.collected) do
          if not collected then
            return
          end
        end

        cassette:set("system/stage", "livingroom")

        timermanager:singleshot(1000, function()
          local effect = scene:get("door", SceneType.effect)
          local door = scene:get("door", SceneType.object)
          door:on_touch(function()
            scribe:clear()
            scenemanager:set("livingroom")
          end)

          door.action = "default"

          timermanager:singleshot(3000, function()
            effect:play()
          end)
        end)
      end)
    end
  end

  local layout = scene:get("layout", SceneType.object)
  local character = scene:get("boy", SceneType.object)
  pool.inventory = Inventory.new(layout, character, objects)

  noise:on_finish(function()
    scribe:write("I drown your divinity in the acheron of my soul.", 4, 5)
    scribe:on_finish(12000, function()
      scribe:clear()
    end)
  end)
end

function scene.on_loop(delta)
  noise:loop()
  scribe:loop(delta)
  pool.inventory:loop(delta)
end

function scene.on_touch()
  pool.missclicks = pool.missclicks + 1
  if pool.missclicks >= 6 then
    pool.beelzebuuth.action = "summon"
    pool.missclicks = 0
  end

  -- if lock then
  -- 	return
  -- end

  pool.touches = (pool.touches or 0) + 1
  pool.threshold = pool.threshold or math.random(3, 6)

  if pool.touches < pool.threshold then
    return
  end

  pool.threshold = math.random(3, 6)
  pool.touches = 0
  -- lock = true

  local candidates = {}
  for name in pairs(items) do
    if not cassette:get(prefix .. name, false) then
      table.insert(candidates, name)
    end
  end

  if #candidates > 0 and math.random() < 0.8 then
    local chosen = candidates[math.random(#candidates)]
    scribe:clear()
    scribe:write(items[chosen].hint, 3, 3)
    scribe:on_finish(3000, function()
      scribe:clear()
      --  lock = false
    end)
    return
  end

  -- timermanager:singleshot(1000, function()
  -- 	lock = false
  -- end)
end

function scene.on_motion(x, y)
  pool.inventory:on_motion(x, y)
end

function scene.on_leave()
  noise:teardown()

  for _, id in ipairs(pool.timers) do
    timermanager:clear(id)
  end

  for o in pairs(pool) do
    pool[o] = nil
  end
end

return scene
