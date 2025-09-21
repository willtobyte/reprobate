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

local animations = {
  antiquewallclock = {
    message = {
      "The sands of time for me are running low...",
      "Dawn no longer comes.",
    },
  },
  baphomet = {
    message = {
      "Hell? The worst torment is to live in this realm of hypocrisy.",
    },
  },
  bloodpriest = {
    message = {
      "...Cast into the fields of evil pleasure.",
      "Hear they dead lips...",
    },
  },
  pictures = {
    minimum = 4,
    maximum = 10,
    action = "moving",
    message = { "What you seek, I control without help." },
  },
  mirrors = {
    message = { "Banished, cold, alone, through the mirror I watch, aeons away." },
  },
  ogremask = {
    message = { "Oni no tsume de omae no tamashii o hikisake." },
  },
  window = {
    minimum = 8,
    maximum = 14,
    action = "lightning",
    message = { "You cannot escape your own mind." },
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

  for name, conf in pairs(animations) do
    local object = scene:get(name, SceneType.object)

    local timed = conf.minimum and conf.maximum or false

    if timed then
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
      local messages = conf.message
      local message = messages[math.random(#messages)]

      say(message, 3, 3, 3000)
    end)

    pool[name] = object
  end

  pool.cabinetdoor = scene:get("cabinetdoor", SceneType.object)
  pool.voodoodoll = scene:get("voodoodoll", SceneType.object)
  pool.cabinetdoor:on_touch(function()
    pool.cabinetdoor.action = "open"
    pool.voodoodoll.action = "default"

    visibility.appear(pool.voodoodoll)

    local warning = "The doll is not yours, it belongs to the loa that rides it."

    say(warning, 3, 3, 3000)
  end)
end

function scene.on_loop(delta)
  lightning:loop()
  scribe:loop(delta)
  -- pool.inventory:loop(delta)
end

function scene.on_leave()
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
