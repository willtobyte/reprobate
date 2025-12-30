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

  pool.binarymessage:on_hover(function()
    pool.binarymessage.action = "default"
  end)
  pool.binarymessage:on_unhover(function()
    pool.binarymessage.action = "hidden"
  end)

  pool.pearintosh:on_touch(jump.to("pearintosh"))

  pool.minisourcecode:on_touch(function()
    if pool.sourcecode.action ~= "default" then
      pool.sourcecode.action = "default"
    else
      pool.sourcecode.action = nil
    end
  end)

  local magazine = pool["HUD/playboy"]
  pool.inventory = Inventory.new(pool.layout, pool.boy, { magazine })

  if state.sourcecode then
    pool.minisourcecode.action = "default"
    magazine.action = nil
  end
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
  pool.inventory.teardown()
  tweens.teardown()
end

sentinel(scene, "highschool")

return scene
