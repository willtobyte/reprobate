local lantern = require("effects/lantern")

local scene = {}

local pool = {}

function scene.on_enter() end

function scene.on_motion(x, y)
	lantern:motion(x, y)
end

function scene.on_loop()
	lantern:loop()
end

function scene.on_leave()
	for o in pairs(pool) do
		pool[o] = nil
	end
end

return scene
