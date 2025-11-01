local scene = {}

local pool = {}

function scene.on_enter()
  pool.light = scene:get("light", SceneType.object)

  pool.switch = scene:get("switch", SceneType.object)

  if state.switch == "on" then
    pool.switch.action = "on"
    pool.light.action = "blinking"
  elseif state.switch == "off" then
    pool.switch.action = "off"
    pool.light.action = nil
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
  end)
end

function scene.on_motion(x, y) end

function scene.on_loop() end

function scene.on_leave()
  pool = {}
end

sentinel(scene, "chemistrylab")

return scene
