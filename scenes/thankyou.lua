local pentagram = require("effects/pentagram")

local scene = {}

local pool = setmetatable({}, { __mode = "k" })

function scene.on_enter() end

function scene.on_loop()
  pentagram:loop()
end

function scene.on_leave()
  for o in pairs(pool) do
    pool[o] = nil
  end
end

return scene
