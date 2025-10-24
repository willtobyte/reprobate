local scene = {}

local pool = {}

local funcs = {}

local prefix = "livingroom/"

local lightning = require("effects/lightning")
local toolbox = require("helpers/toolbox")
local tween = require("library/tween")

local Scribe = require("helpers/scribe")
local say = Scribe.say
local scribe = Scribe.scribe

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

  pool.tweens = {
    appear = {},
    disappear = {},
  }

  pool.collected = {}

  pool.teenager = scene:get("teenager", SceneType.object)
  pool.voodoocast = scene:get("voodoocast", SceneType.object)

  for name, conf in pairs(objects) do
    local object = scene:get(name, SceneType.object)

    pool[name] = object

    local bounded = conf.minimum and conf.maximum or false
    if bounded then
      local delay = math.random(conf.minimum, conf.maximum) * 1000

      timermanager:set(delay, function()
        object.action = conf.action

        if conf.lightning then
          lightning:trigger()
        end
      end)
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
      pool.cabinetdoor:on_touch(nil)
      pool.cabinetdoor.action = "open"
      pool.voodoodoll.action = "default"
      pool.voodoodoll.alpha = 0
      pool.tweens.appear[#pool.tweens.appear + 1] = tween.new(1, pool.voodoodoll, { alpha = 255 })

      local message = "The doll is not yours, it belongs to the loa that rides it."
      say(message, 3, 3, 3000)

      cassette:set(key, true)
    end)
  end

  for name, _ in pairs(items) do
    local object = scene:get(name, SceneType.object)
    local key = prefix .. name
    pool[name] = object

    local taken = cassette:get(key, false)

    pool.collected[name] = taken

    if taken then
      object.visible = false
    else
      object:on_touch(function(self)
        pool.collected[name] = true
        cassette:set(key, true)

        pool.tweens.disappear[#pool.tweens.disappear + 1] =
          tween.new(1, self, { alpha = 0, angle = 360, scale = 1.5 }, "inOutQuad")

        funcs:on_all()
      end)
    end
  end
end

function funcs:on_all()
  if not toolbox.all(pool.collected) then
    return
  end

  cassette:set("system/stage", "highschool")

  timermanager:singleshot(3000, function()
    lightning:teardown()
    scribe:clear()

    for _, object in pairs(pool) do
      if object.visible ~= nil then
        object.visible = false
      end
    end

    pool.teenager.action = "default"
    pool.teenager.alpha = 200
    pool.tweens.appear[#pool.tweens.appear + 1] = tween.new(1, pool.teenager, { alpha = 255 })

    timermanager:singleshot(3000, function()
      pool.teenager.action = nil
      pool.teenager.action = "default"

      pool.voodoocast.action = "default"
      pool.voodoocast.alpha = 0
      pool.tweens.appear[#pool.tweens.appear + 1] = tween.new(1, pool.voodoocast, { alpha = 255 })

      timermanager:singleshot(6000, function()
        scenemanager:set("highschool")
      end)
    end)
  end)
end

function scene.on_loop(delta)
  lightning:loop()
  scribe:loop(delta)
  -- pool.inventory:loop(delta)

  local function step(list, hide)
    local n = #list
    if n == 0 then
      return
    end

    for i = n, 1, -1 do
      local t = list[i]
      if t:update(delta) then
        if t.subject and hide then
          t.subject.visible = false
        end

        list[i] = list[n]
        list[n] = nil
        n = n - 1
      end
    end
  end

  step(pool.tweens.appear, false)
  step(pool.tweens.disappear, true)
end

function scene.on_leave()
  scribe:clear()
  lightning:teardown()

  for key in next, pool do
    pool[key] = nil
  end
end

sentinel(scene, "livingroom")

return scene
