local scene = {}

local pool = {}

local lantern = require("effects/lantern")

local prefix = "chemistrylab/"

function scene.on_enter()
  pool.switch = scene:get("switch", SceneType.object)

  pool.cabinetdoor = scene:get("cabinetdoor", SceneType.object)
  pool.cabinetdoor:on_touch(function()
    pool.cabinetdoor.action = "open"
    pool.switch.action = "off"
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
