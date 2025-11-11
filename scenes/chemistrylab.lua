local scene = {}

local pool = {}

local tween = require("library/tween")
local Scribe = require("helpers/scribe")
local say = Scribe.say
local scribe = Scribe.scribe

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
}

local function verify()
  if all(items, "taken") then
    -- TODO
  end
end

local function setup()
  pool.light = scene:get("light", SceneType.object)

  pool.switch = scene:get("switch", SceneType.object)
  local switch = state.switch
  if switch == "on" then
    pool.switch.action, pool.light.action = "on", "blinking"
  elseif switch == "off" then
    pool.switch.action, pool.light.action = "off", nil
  end

  pool.bottomcabinetdoor = scene:get("bottomcabinetdoor", SceneType.object)
  if state.bottomcabinetdoor then
    pool.bottomcabinetdoor.action = "open"
  end
  pool.bottomcabinetdoor:on_touch(function()
    state.bottomcabinetdoor = true
    pool.bottomcabinetdoor.action = "open"
  end)

  pool.cabinetdoor = scene:get("cabinetdoor", SceneType.object)
  if state.cabinetdoor then
    pool.cabinetdoor.action = "open"
    pool.switch.action = state.switch
  end

  pool.cabinetdoor:on_touch(function()
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
    local object = scene:get(name, SceneType.object)

    object:on_touch(function()
      local messages = conf.messages
      local count = #messages
      local index = math.random(count)
      local message = messages[index]
      say(message, 3, 3, 3000)
    end)

    pool[name] = object
  end

  for name, conf in pairs(items) do
    local object = scene:get(name, SceneType.object)
    pool[name] = object

    conf.taken = not not state[name]
    object.visible = not conf.taken
    object:on_touch(function(self)
      if conf.taken then
        return
      end

      conf.taken = true
      state[name] = true
      pool.tweens.disappear[#pool.tweens.disappear + 1] =
        tween.new(1, self, { alpha = 0, angle = 360, scale = 1.6 }, "inOutQuad")

      verify()
    end)
  end
end

function scene.on_enter()
  pool.tweens = {
    appear = {},
    disappear = {},
  }

  pool.alien = scene:get("alien", SceneType.object)
  pool.geigercounter = scene:get("geigercounter", SceneType.effect)
  pool.geigercounter:play(true)

  pool.emitter1 = scene:get("emitter1", SceneType.particle)
  pool.emitter2 = scene:get("emitter2", SceneType.particle)
  pool.emitter3 = scene:get("emitter3", SceneType.particle)

  if state.fireextinguished then
    pool.emitter1.active = false
    pool.emitter2.active = false
    pool.emitter3.active = false

    setup()
  end

  pool.fireextinguisher = scene:get("fireextinguisher", SceneType.object)
  pool.fireextinguisher:on_touch(function()
    state.fireextinguished = true
    pool.emitter1.emitting = false
    pool.emitter2.emitting = false
    pool.emitter3.emitting = false

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
  scribe:loop(delta)

  if not pool.alien.visible then
    pool.geigercounter:stop()
  end

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

sentinel(scene, "chemistrylab")

return scene
