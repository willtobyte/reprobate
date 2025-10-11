local scene = {}

local pool = {}

local timers = {}

local prefix = "livingroom/"

local lightning = require("effects/lightning")
local toolbox = require("helpers/toolbox")
local visibility = require("helpers/visibility")

local Scribe = require("helpers/scribe")
local say = Scribe.say
local scribe = Scribe.scribe

local cassette = engine:cassette()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()

local objects = {
  antiquewallclock = {
    messages = {
      "Dawn no longer comes.",
      "Time catches up with everyone;\nSooner or later, the moment will come.",
    },
  },
  baphomet = {
    messages = {
      "Hell? The worst torment is to live in this realm of hypocrisy.",
    },
  },
  bloodpriest = {
    messages = {
      "...Cast into the fields of evil pleasure.",
      "Hear they dead lips...",
    },
  },
  pictures = {
    minimum = 4,
    maximum = 10,
    action = "moving",
    messages = { "What you seek, I control without help." },
  },
  mirrors = {
    messages = { "Banished, cold, alone, through the mirror I watch, aeons away." },
  },
  ogremask = {
    messages = { "Oni no tsume de omae no tamashii o hikisake." },
  },
  window = {
    minimum = 8,
    maximum = 16,
    action = "lightning",
    messages = { "You cannot escape your own mind." },
    lightning = true,
  },
}

local items = {
  sugarcanespirit = {},
  voodoodoll = {},
}

function scene.on_enter()
  scenemanager:destroy("mainmenu")
  scenemanager:destroy("whobuilt")
  scenemanager:destroy("babyroom")
  scenemanager:register("highschool")
  cassette:set("system/stage", "livingroom")

  pool.theme = scene:get("rainmuffled", SceneType.effect)
  pool.theme:play(true)

  pool.collected = {}

  pool.teenager = scene:get("teenager", SceneType.object)
  pool.voodoocast = scene:get("voodoocast", SceneType.object)

  for name, conf in pairs(objects) do
    local object = scene:get(name, SceneType.object)

    pool[name] = object

    local bounded = conf.minimum and conf.maximum or false
    if bounded then
      local delay = math.random(conf.minimum, conf.maximum) * 1000

      local id = timermanager:set(delay, function()
        object.action = conf.action

        if conf.lightning then
          lightning:trigger()
        end
      end)

      table.insert(timers, id)
    end

    object:on_touch(function()
      local messages = conf.messages
      if messages then
        say(messages[math.random(#messages)], 3, 3, 3000)
      end
    end)
  end

  pool.cabinetdoor = scene:get("cabinetdoor", SceneType.object)
  pool.voodoodoll = scene:get("voodoodoll", SceneType.object)

  local key = prefix .. "cabinetdoor"

  if cassette:get(key) then
    pool.cabinetdoor.action = "open"
    pool.voodoodoll.action = "default"
  else
    pool.cabinetdoor:on_touch(function()
      pool.cabinetdoor.action = "open"
      pool.voodoodoll.action = "default"

      visibility.appear(pool.voodoodoll)

      local message = "The doll is not yours, it belongs to the loa that rides it."
      say(message, 3, 3, 3000)

      cassette:set(key, true)
    end)
  end

  for name, _ in pairs(items) do
    local object = scene:get(name, SceneType.object)
    local key = prefix .. name
    local done = cassette:get(key, false)
    pool[name] = object

    pool.collected[name] = done

    if done then
      object:hide()
    else
      object:on_touch(function(self)
        pool.collected[name] = true
        cassette:set(key, true)
        visibility.disappear(self)

        if not toolbox.all(pool.collected) then
          return
        end

        cassette:set("system/stage", "highschool")

        for i = 1, #timers do
          timermanager:clear(timers[i])
        end
        timers = {}

        pool.theme:stop()

        local id = timermanager:singleshot(3000, function()
          scribe:clear()
          lightning:teardown()

          pool.teenager.action = "default"
          visibility.appear(pool.teenager)

          local id = timermanager:singleshot(3000, function()
            pool.voodoocast.action = "default"
            visibility.appear(pool.voodoocast)

            local id = timermanager:singleshot(6000, function()
              scenemanager:set("highschool")
            end)

            table.insert(timers, id)
          end)

          table.insert(timers, id)
        end)

        table.insert(timers, id)
      end)
    end
  end
end

function scene.on_loop(delta)
  lightning:loop()
  scribe:loop(delta)
  -- pool.inventory:loop(delta)
end

function scene.on_leave()
  scribe:clear()
  lightning:teardown()

  for i = 1, #timers do
    timermanager:clear(timers[i])
  end
  timers = {}

  for name in next, pool do
    pool[name] = nil
  end
end

sentinel(scene, "livingroom")

return scene
