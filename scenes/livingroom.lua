local scene = {}

local pool = {}

local timers = {}

local prefix = "livingroom/"

local lightning = require("effects/lightning")

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
    maximum = 14,
    action = "lightning",
    messages = { "You cannot escape your own mind." },
    lightning = true,
  },
}

function scene.on_enter()
  scenemanager:destroy("mainmenu")
  scenemanager:destroy("whobuilt")
  scenemanager:destroy("babyroom")
  scenemanager:register("highschool")
  cassette:set("system/stage", "livingroom")

  pool.theme = scene:get("rainmuffled", SceneType.effect)
  pool.theme:play(true)

  for name, conf in pairs(objects) do
    local object = scene:get(name, SceneType.object)

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
      local message = messages[math.random(#messages)]

      say(message, 3, 3, 3000)
    end)

    pool[name] = object
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
end

function scene.on_loop(delta)
  lightning:loop()
  scribe:loop(delta)
  -- pool.inventory:loop(delta)
end

function scene.on_leave()
  scribe:clear()
  lightning:teardown()

  for _, id in ipairs(timers) do
    timermanager:clear(id)
  end

  for name in pairs(pool) do
    pool[name] = nil
  end
end

sentinel(scene, "livingroom")

return scene
