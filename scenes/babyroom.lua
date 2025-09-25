local scene = {}

local pool = {}

local timers = {}

local prefix = "babyroom/"

local Inventory = require("overlay/inventory")

local Scribe = require("helpers/scribe")
local say = Scribe.say
local scribe = Scribe.scribe

local visibility = require("helpers/visibility")

local noise = require("effects/noise")

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
  crucifix = { damage = true },
  gijoe = { damage = false },
  nintendo = { damage = false },
  playboy = { damage = false },
}

function scene.on_enter()
  scenemanager:destroy("mainmenu")
  scenemanager:destroy("whobuilt")
  scenemanager:register("livingroom")
  cassette:set("system/stage", "babyroom")

  achievement:unlock("NEW_ACHIEVEMENT_3_3")

  pool.collected = {}
  pool.missclicks = 0
  pool.television = scene:get("television", SceneType.object)
  pool.beelzebuuth = scene:get("beelzebuuth", SceneType.object)

  pool.television:on_touch(function()
    say("This game is haunted, can you feel it?")
  end)

  for name, conf in pairs(animations) do
    local message = conf.message
    local object = scene:get(name, SceneType.object)
    pool[name] = object

    local delay = math.random(conf.minimum, conf.maximum) * 1000
    local action = conf.action
    local id = timermanager:set(delay, function()
      pool[name].action = action
    end)

    table.insert(timers, id)

    object:on_touch(function()
      say(message)
    end)
  end

  local objects = {}

  for name, conf in pairs(items) do
    local key = prefix .. name
    local object = scene:get(name, SceneType.object)
    pool[name] = object

    local hn = "HUD/" .. name
    local item = scene:get(hn, SceneType.object)
    pool[hn] = item
    table.insert(objects, item)

    local done = cassette:get(key, false)

    pool.collected[name] = done

    if done then
      object:hide()
      item.action = "default"
    end

    if not done then
      object:on_touch(function(self)
        if conf.damage then
          overlay:dispatch(WidgetType.cursor, "damage")
        end

        pool.television.action = "poltergeist"
        pool.collected[name] = true

        cassette:set(key, true)

        visibility.disappear(self)
        pool[hn].action = "default"

        for _, collected in pairs(pool.collected) do
          if not collected then
            return
          end
        end

        cassette:set("system/stage", "livingroom")

        local id = timermanager:singleshot(1000, function()
          local door = scene:get("door", SceneType.object)
          door:on_touch(function()
            scenemanager:set("livingroom")
          end)

          door.action = "default"

          -- achievement:unlock("")

          local id = timermanager:singleshot(3000, function()
            local effect = scene:get("door", SceneType.effect)
            if effect then
              effect:play()
            end
          end)

          table.insert(timers, id)
        end)

        table.insert(timers, id)
      end)
    end
  end

  local layout = scene:get("layout", SceneType.object)
  local character = scene:get("boy", SceneType.object)
  pool.inventory = Inventory.new(layout, character, objects)

  noise:on_finish(function()
    noise:teardown()

    say("I drown your divinity in the acheron of my soul.", 3, 3, 12000)
  end)

  noise:init()
end

function scene.on_touch()
  pool.missclicks = pool.missclicks + 1
  if pool.missclicks >= 6 then
    pool.beelzebuuth.action = "summon"
    pool.missclicks = 0
  end
end

function scene.on_motion(x, y)
  pool.inventory:on_motion(x, y)
end

function scene.on_loop(delta)
  noise:loop()
  scribe:loop(delta)

  pool.inventory:loop(delta)
end

function scene.on_leave()
  scribe:clear()

  for _, id in ipairs(timers) do
    timermanager:clear(id)
  end

  for name in pairs(pool) do
    pool[name] = nil
  end
end

sentinel(scene, "babyroom")

return scene
