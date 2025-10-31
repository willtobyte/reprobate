local scene = {}

local pool = {}

local prefix = "chemistrylab/"

local state = {}

local meta = {}

function meta.__newindex(table, key, value)
  cassette:set(prefix .. key, value)
  rawset(table, key, value)
end

setmetatable(state, meta)

local lantern = require("effects/lantern")

function scene.on_enter()
  pool.switch = scene:get("switch", SceneType.object)

  pool.cabinetdoor = scene:get("cabinetdoor", SceneType.object)
  pool.cabinetdoor:on_touch(function()
    pool.cabinetdoor.action = "open"
    pool.switch.action = "off"

    state.foo = "bar"
  end)

  pool.emitter1 = scene:get("emitter1", SceneType.particle)
  pool.emitter2 = scene:get("emitter2", SceneType.particle)
  pool.emitter3 = scene:get("emitter3", SceneType.particle)

  pool.fireextinguisher = scene:get("fireextinguisher", SceneType.object)
  pool.fireextinguisher:on_touch(function()
    pool.emitter1.emitting = false
    pool.emitter2.emitting = false
    pool.emitter3.emitting = false
  end)

  pool.lighton = cassette:get(prefix .. "lighton", true)
  if pool.lighton then
    -- Enable clicks
  end
end

function scene.on_motion(x, y)
  if not pool.lighton then
    lantern:motion(x, y)
  end
end

function scene.on_loop()
  if not pool.lighton then
    lantern:loop()
  end
end

function scene.on_leave()
  lantern:teardown()

  pool = {}
end

sentinel(scene, "chemistrylab")

return scene
