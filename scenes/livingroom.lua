local scene = {}

local pool = {}

local jump = require("helpers/jump")
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
    minimum = 4,
    maximum = 8,
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

    timermanager:singleshot(3000, function()
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

        timermanager:singleshot(3000, function()
          pool.teenager:on_touch(jump.to("highschool"))
        end)
      end)
    end)
  end
end

function scene.on_enter()
  state.system.stage = "livingroom"

  transition({
    destroy = { "mainmenu", "whobuilt", "babyroom" },
    register = { "highschool" },
  })

  pool.theme = scene:get("rainmuffled", SceneType.effect)
  pool.theme:play(true)

  pool.tweens = {
    appear = {},
    disappear = {},
  }

  pool.teenager = scene:get("teenager", SceneType.object)
  pool.voodoocast = scene:get("voodoocast", SceneType.object)

  pool.darker = scene:get("darker", SceneType.object)

  for name, conf in pairs(objects) do
    local object = scene:get(name, SceneType.object)

    pool[name] = object

    local bounded = conf.minimum ~= nil and conf.maximum ~= nil
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

  if state.cabinetdoor then
    pool.cabinetdoor.action = "open"
    pool.voodoodoll.action = "default"
  else
    pool.cabinetdoor:on_touch(function()
      state.cabinetdoor = true
      pool.cabinetdoor.action = "open"
      pool.voodoodoll.action = "default"
      pool.voodoodoll.alpha = 0
      pool.tweens.appear[#pool.tweens.appear + 1] = tween.new(1, pool.voodoodoll, { alpha = 255 })

      local message = "The doll is not yours, it belongs to the loa that rides it."
      say(message, 3, 3, 3000)
      state.cabinetdoor = true
    end)
  end

  for name, conf in pairs(items) do
    local object = scene:get(name, SceneType.object)
    pool[name] = object

    conf.taken = not not state[name]
    object.visible = not conf.taken
    object:on_touch(function(self)
      conf.taken = true
      state[name] = true

      pool.tweens.disappear[#pool.tweens.disappear + 1] =
        tween.new(1, self, { alpha = 0, angle = 360, scale = 1.5 }, "inOutQuad")

      verify()
    end)
  end
end

function scene.on_loop(delta)
  scribe:loop(delta)
  -- pool.inventory:loop(delta)

  lightning:update()

  local function step(tweens, hide)
    local n = #tweens
    if n == 0 then
      return
    end

    for i = n, 1, -1 do
      local t = tweens[i]
      if t:update(delta) then
        if t.subject and hide then
          t.subject.visible = false
        end

        tweens[i] = tweens[n]
        tweens[n] = nil
        n = n - 1
      end
    end
  end

  step(pool.tweens.appear, false)
  step(pool.tweens.disappear, true)
end

function scene.on_leave()
  scribe:clear()

  pool = {}
end

sentinel(scene, "livingroom")

return scene
