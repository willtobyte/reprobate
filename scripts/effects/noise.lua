local MAX_COLOR = 0x010101
local ALPHA_SHIFT = 0x01000000

local NoiseEffect = {}
NoiseEffect.__index = NoiseEffect

function NoiseEffect:new(width, height, duration)
	local self = setmetatable({}, NoiseEffect)

	self.canvas = engine:canvas()
	self.width = width or 480
	self.height = height or 270
	self.pixels = {}
	self.start_time = nil
	self.duration = duration or 1000
	self.callback = nil

	self.floor = math.floor
	self.random = math.random

	return self
end

function NoiseEffect:init()
	self.start_time = ticks()
end

function NoiseEffect:on_finish(callback)
	self.callback = callback
end

function NoiseEffect:loop()
	local elapsed = ticks() - self.start_time
	local alpha = (elapsed < self.duration) and self.floor(255 * (1 - elapsed / self.duration)) or 0

	if alpha == 0 then
		if self.callback then
			self.callback()
			self.callback = nil
		end
		return
	end

	local offset = alpha * ALPHA_SHIFT
	local index = 1

	for y = 0, self.height - 1 do
		local multiplier = (y % 2 == 0) and 0.7 or 1.0

		for x = 0, self.width - 1 do
			local intensity = self.random(0, 255)
			if multiplier ~= 1.0 then
				intensity = self.floor(intensity * multiplier)
			end
			self.pixels[index] = offset + intensity * MAX_COLOR
			index = index + 1
		end
	end

	self.canvas.pixels = self.pixels
end

function NoiseEffect:teardown() end

return NoiseEffect:new()
