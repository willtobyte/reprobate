local scene = {}

local Inventory = require("overlay/inventory")

local tweens = require("helpers/tweens")
local scribe = require("helpers/scribe")

function scene.on_enter()
  state.system.stage = "highschool"

  transition({
    destroy = { "mainmenu", "whobuilt", "livingroom" },
    register = { "pearintosh" },
  })

  local magazine = pool["HUD/playboy"]
  pool.inventory = Inventory.new(pool.layout, pool.boy, { magazine })

  if not state.sourcecode then
    return
  end
  pool.minisourcecode.action = "default"
  magazine.action = nil
end

function scene.on_motion(x, y)
  pool.inventory.motion(x, y)
end

function scene.on_touch() end

function scene.on_loop(delta)
  scribe.loop(delta)
  pool.inventory.loop(delta)
  tweens.loop(delta)
end

function scene.on_leave()
  scribe.clear()
  tweens.teardown()
  pool.inventory.teardown()
end

sentinel(scene, "highschool")

return scene
