local scene = {}

local tween = require("library/tween")
local tweens = require("helpers/tweens")
local scribe = require("helpers/scribe")
local say = scribe.say

local objects = {
  alien = {
    messages = {
      "I swear, officer... It was just one Space Beer!",
      "Houston, I have a hangover...",
    },
  },
  testtubes = {
    messages = {
      "teste",
    },
  },
}

local items = {
  openendwrench = {},
  smallkey = {},
  gasoline = {},
  tubeamplifier = {},
}

local function verify()
  if all(items, "taken") then
    -- TODO
  end
end

local function setup()
  local switch = state.switch
  if switch == "on" then
    pool.switch.action, pool.light.action = "on", "blinking"
  elseif switch == "off" then
    pool.switch.action, pool.light.action = "off", nil
  end

  if state.bottomcabinetdoor then
    pool.bottomcabinetdoor.action = "open"
    pool.tubeamplifier.action = "default"
  end
  pool.bottomcabinetdoor:on_touch(function()
    pool.bottomcabinetdoor:on_touch(nil)
    state.bottomcabinetdoor = true
    pool.bottomcabinetdoor.action = "open"

    pool.tubeamplifier.action = "default"
    pool.tubeamplifier.alpha = 0
    tweens.appear.tubeamplifier = tween.new(1, pool.tubeamplifier, { alpha = 255 })
  end)

  if state.cabinetdoor then
    pool.cabinetdoor.action = "open"
    pool.switch.action = state.switch
  end

  pool.cabinetdoor:on_touch(function()
    pool.cabinetdoor:on_touch(nil)
    pool.cabinetdoor.action = "open"

    state.cabinetdoor = true
    pool.switch.action = "on"
    state.switch = "on"
  end)

  pool.switch:on_touch(function()
    pool.light.action = nil
    pool.switch.action = "off"
    state.switch = "off"
  end)

  for name, conf in pairs(objects) do
    local object = pool[name]

    object:on_touch(function()
      local messages = conf.messages
      local count = #messages
      local index = math.random(count)
      local message = messages[index]
      say(message, 3, 3, 3000)
    end)
  end

  for name, conf in pairs(items) do
    local object = pool[name]

    conf.taken = not not state[name]
    object.visible = not conf.taken
    object:on_touch(function(self)
      object:on_touch(nil)
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

function scene.on_enter()
  state.system.stage = "chemistrylab"

  pool.geigercounter:play(true)

  if state.fireextinguished then
    pool.emitter1.spawning = false
    pool.emitter2.spawning = false
    pool.emitter3.spawning = false

    setup()
  end

  pool.fireextinguisher:on_touch(function()
    state.fireextinguished = true
    pool.emitter1.spawning = false
    pool.emitter2.spawning = false
    pool.emitter3.spawning = false

    setup()
  end)
end

function scene.on_motion(x, y)
  local alien_x, alien_y, alien_w, alien_h = 249, 183, 127, 48
  local cx = alien_x + alien_w * 0.5
  local cy = alien_y + alien_h * 0.5

  local dx, dy = x - cx, y - cy
  local distance = math.sqrt(dx * dx + dy * dy)

  local r_max = math.min(cx, 480 - cx, cy, 270 - cy)
  if r_max <= 0 then
    return
  end

  local t = math.min(distance / r_max, 1.0)
  local volume = 1.0 - 0.9 * t

  pool.geigercounter.volume = volume
end

function scene.on_loop(delta)
  scribe.loop(delta)
  if not pool.alien.visible then
    pool.geigercounter:stop()
  end
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

sentinel(scene, "chemistrylab")

return scene
