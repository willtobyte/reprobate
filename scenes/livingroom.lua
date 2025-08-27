local scene = {}

local scribe = require("helpers/scribe")
local lightning = require("effects/lightning")
local visibility = require("helpers/visibility")

local pool = {}
local prefix = "livingroom/"

local cassette = engine:cassette()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()

local R = math.random
local insert = table.insert
local pairs = pairs
local ipairs = ipairs

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
      "Hear her dead lips...",
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

local function say(msg, x, y, ms)
  scribe:clear()
  scribe:write(msg, x or 3, y or 3)
  scribe:on_finish(ms or 3000, function()
    scribe:clear()
  end)
end

function scene.on_enter()
  pool.timers = {}

  scenemanager:destroy("*")

  local rainmuffled = scene:get("rainmuffled", SceneType.effect)
  rainmuffled:play(true)

  for name, settings in pairs(animations) do
    local object = scene:get(name, SceneType.object)
    pool[name] = object

    local timed = settings.minimum and settings.maximum
    if timed then
      local delay = R(settings.minimum, settings.maximum) * 1000
      local id = timermanager:set(delay, function()
        object.action = settings.action
        if settings.lightning then
          lightning:trigger()
        end
      end)
      insert(pool.timers, id)
    end

    object:on_touch(function()
      say(settings.message[R(#settings.message)], 3, 3, 3000)
    end)
  end

  pool.cabinetdoor = scene:get("cabinetdoor", SceneType.object)
  pool.voodoodoll = scene:get("voodoodoll", SceneType.object)

  pool.cabinetdoor:on_touch(function()
    pool.cabinetdoor.action = "open"
    pool.voodoodoll.action = "default"
    visibility.appear(pool.voodoodoll)
    say("The doll is not yours, it belongs to the loa that rides it.", 3, 3, 3000)
  end)
end

function scene.on_motion(x, y) end

function scene.on_loop(delta)
  lightning:loop()
  scribe:loop(delta)
end

function scene.on_leave()
  for _, id in ipairs(pool.timers) do
    timermanager:clear(id)
  end

  pool = {}
end

return scene
