local Effect = {}
Effect.__index = Effect

local rep, char = string.rep, string.char

function Effect:new()
	local width, height = 480, 270

	local pixel = char(0, 0, 255, 255)

	local line = rep(pixel, width)

	local frame = rep(line, height)

	return setmetatable({
		canvas = engine:canvas(),
		frame = frame,
	}, self)
end

function Effect:loop()
	self.canvas.pixels = self.frame
end

return Effect:new()
