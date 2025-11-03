local scene = {}

local pool = {}

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
}

local function ready()
  pool.light = scene:get("light", SceneType.object)

  pool.switch = scene:get("switch", SceneType.object)
  local s = state.switch
  if s == "on" then
    pool.switch.action, pool.light.action = "on", "blinking"
  elseif s == "off" then
    pool.switch.action, pool.light.action = "off", nil
  end

  pool.bottomcabinetdoor = scene:get("bottomcabinetdoor", SceneType.object)
  if state.cabinetdoor then
    pool.bottomcabinetdoor.action = "open"
  end
  pool.bottomcabinetdoor:on_touch(function()
    state.cabinetdoor = "open"
    pool.bottomcabinetdoor.action = "open"
  end)

  pool.cabinetdoor = scene:get("cabinetdoor", SceneType.object)
  if state.cabinetdoor then
    pool.cabinetdoor.action = "open"
    pool.switch.action = state.switch
  else
    pool.switch.action = nil
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
end

function scene.on_enter()
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

    ready()
  end

  pool.fireextinguisher = scene:get("fireextinguisher", SceneType.object)
  pool.fireextinguisher:on_touch(function()
    state.fireextinguished = true
    pool.emitter1.emitting = false
    pool.emitter2.emitting = false
    pool.emitter3.emitting = false

    ready()
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
end

function scene.on_leave()
  scribe:clear()

  pool = {}
end

sentinel(scene, "chemistrylab")

return scene
