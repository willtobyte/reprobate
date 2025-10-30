local scene = {}

local pool = {}

local lantern = require("effects/lantern")
local prefix = "chemistrylab/"

function scene.on_enter()
  pool.lighton = cassette:get(prefix .. "lighton", false)
  if pool.lighton then
    -- Enable clicks
  end
end

function scene.on_motion(x, y)
  error("Motion event not implemented")
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
