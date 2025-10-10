local scene = {}

local pool = {}

local timers = {}

local prefix = "babyroom/"

local Inventory = require("overlay/inventory")

local ops = require("helpers/ops")
local prank = require("helpers/prank")
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
  gijoe = {},
  nintendo = {},
  playboy = {},
}

function scene.on_enter()
  scenemanager:destroy("mainmenu")
  scenemanager:destroy("whobuilt")
  scenemanager:register("livingroom")
  cassette:set("system/stage", "babyroom")

  prank.write("iseeyou.txt", "TODO...")

  pool.collected = {}
  pool.television = scene:get("television", SceneType.object)
  pool.beelzebuuth = scene:get("beelzebuuth", SceneType.object)

  pool.beelzebuuth.misses:subscribe(function(value)
    if value >= 6 then
      pool.beelzebuuth.action = "summon"
      pool.beelzebuuth.misses = 0
    end
  end)

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

    local hud = "HUD/" .. name
    local item = scene:get(hud, SceneType.object)
    pool[hud] = item
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
        pool[hud].action = "default"

        for i = 1, #pool.collected do
          if not pool.collected[i] then
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
  ops.incr(pool.beelzebuuth.misses)
end

function scene.on_motion(x, y)
  pool.inventory:motion(x, y)
end

function scene.on_loop(delta)
  noise:loop()
  scribe:loop(delta)

  pool.inventory:loop(delta)
end

function scene.on_leave()
  pool.inventory:teardown()
  scribe:clear()

  for i = 1, #timers do
    timermanager:clear(timers[i])
  end

  for name in next, pool do
    pool[name] = nil
  end
end

sentinel(scene, "babyroom")

return scene
