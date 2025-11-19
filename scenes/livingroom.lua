local scene = {}

local tween = require("library/tween")
local tweens = require("helpers/tweens")
local scribe = require("helpers/scribe")
local say = scribe.say

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
    minimum = 3,
    maximum = 6,
    action = "lightning",
    messages = { "You cannot escape your own mind." },
    lightning = true,
  },
}

local items = {
  sugarcanespirit = {},
  voodoodoll = {},
}

local lightning = { active = false, next_at = 0, count = 0, total = 0, phase = nil }

function lightning:trigger()
  if self.active then
    return
  end
  self.active = true
  self.count = 0
  self.total = math.random(3, 4)
  self.phase = "bright"
  pool.darker.action = nil
  self.next_at = moment() + math.random(20, 30)
end

function lightning:update()
  if not self.active then
    return
  end

  local now = moment()
  if now < self.next_at then
    return
  end

  if self.phase == "bright" then
    self.count = self.count + 1
    pool.darker.action = "default"
    if self.count >= self.total then
      self.active = false
      self.phase = nil
      return
    end

    self.phase = "dark"
    self.next_at = now + math.random(20, 30)
    return
  end

  pool.darker.action = nil
  self.phase = "bright"
  self.next_at = now + math.random(20, 30)
end

local function verify()
  if all(items, "taken") then
    state.system.stage = "highschool"

    timermanager:singleshot(2000, function()
      scribe.clear()

      for name in pairs(objects) do
        if pool[name] then
          pool[name].visible = false
        end
      end

      pool.teenager.action = "default"
      pool.teenager.alpha = 200
      tweens.appear.teenager = tween.new(1, pool.teenager, { alpha = 255 })
    end)

    timermanager:singleshot(5000, function()
      pool.teenager.action = nil
      pool.teenager.action = "default"

      pool.voodoocast.action = "default"
      pool.voodoocast.alpha = 0
      tweens.appear.voodoocast = tween.new(1, pool.voodoocast, { alpha = 255 })
    end)

    timermanager:singleshot(9000, function()
      scenemanager:set("highschool")
    end)
  end
end

function scene.on_enter()
  state.system.stage = "livingroom"

  transition({
    destroy = { "mainmenu", "whobuilt", "retrostatic", "babyroom" },
    register = { "highschool" },
  })

  pool.theme = scene:get("rainmuffled", SceneKind.effect)
  pool.theme:play(true)

  pool.teenager = scene:get("teenager", SceneKind.object)
  pool.voodoocast = scene:get("voodoocast", SceneKind.object)

  pool.darker = scene:get("darker", SceneKind.object)

  for name, conf in pairs(objects) do
    local object = scene:get(name, SceneKind.object)

    pool[name] = object

    local bounded = conf.minimum ~= nil and conf.maximum ~= nil
    if bounded then
      local delay = math.random(conf.minimum, conf.maximum) * 1000
      local o = object
      local a = conf.action
      local l = conf.lightning

      timermanager:set(delay, function()
        o.action = a
        if l then
          lightning:trigger()
        end
      end)
    end

    object:on_touch(function()
      local messages = conf.messages
      local count = #messages
      local index = math.random(count)
      local message = messages[index]
      say(message, 3, 3, 3000)
    end)
  end

  pool.cabinetdoor = scene:get("cabinetdoor", SceneKind.object)
  pool.voodoodoll = scene:get("voodoodoll", SceneKind.object)

  if state.cabinetdoor then
    pool.cabinetdoor.action = "open"
    pool.voodoodoll.action = "default"
  else
    pool.cabinetdoor:on_touch(function()
      state.cabinetdoor = true
      pool.cabinetdoor.action = "open"
      pool.voodoodoll.action = "default"
      pool.voodoodoll.alpha = 0
      tweens.appear.voodoodoll = tween.new(1, pool.voodoodoll, { alpha = 255 })

      local message = "The doll is not yours, it belongs to the loa that rides it."
      say(message, 3, 3, 3000)
      state.cabinetdoor = true
    end)
  end

  for name, conf in pairs(items) do
    local object = scene:get(name, SceneKind.object)
    pool[name] = object

    conf.taken = not not state[name]
    object.visible = not conf.taken
    object:on_touch(function(self)
      if conf.taken then
        return
      end

      conf.taken = true
      state[name] = true
      tweens.disappear[name] = tween.new(1, self, { alpha = 0, angle = 360, scale = 1.6 }, "inOutQuad")

      verify()
    end)
  end
end

function scene.on_loop(delta)
  scribe.loop(delta)
  -- pool.inventory:loop(delta)

  lightning:update()

  tweens.loop(delta, function(type, name, t)
    if t.subject and type == "disappear" then
      t.subject.visible = false
    end
  end)
end

function scene.on_leave()
  scribe.clear()
  tweens.teardown()
end

sentinel(scene, "livingroom")

return scene
