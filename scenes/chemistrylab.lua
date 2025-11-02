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
      "Hey, bartender! Turn off the stars before they start singing.",
    },
  },
}

function scene.on_enter()
  pool.emitter1 = scene:get("emitter1", SceneType.particle)
  pool.emitter2 = scene:get("emitter2", SceneType.particle)
  pool.emitter3 = scene:get("emitter3", SceneType.particle)

  if state.fireextinguished then
    pool.emitter1.active = false
    pool.emitter2.active = false
    pool.emitter3.active = false
  end

  pool.fireextinguisher = scene:get("fireextinguisher", SceneType.object)
  pool.fireextinguisher:on_touch(function()
    state.fireextinguished = true
    pool.emitter1.emitting = false
    pool.emitter2.emitting = false
    pool.emitter3.emitting = false

    pool.light = scene:get("light", SceneType.object)

    pool.switch = scene:get("switch", SceneType.object)
    local s = state.switch
    if s == "on" then
      pool.switch.action, pool.light.action = "on", "blinking"
    elseif s == "off" then
      pool.switch.action, pool.light.action = "off", nil
    end

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
  end)
end

function scene.on_motion(x, y) end

function scene.on_loop(delta)
  scribe:loop(delta)
end

function scene.on_leave()
  scribe:clear()

  pool = {}
end

sentinel(scene, "chemistrylab")

return scene
