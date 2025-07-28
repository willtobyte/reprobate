local Light = {}
Light.__index = Light

local char, rep, random, moment = string.char, string.rep, math.random, moment

function Light:new(width, height)
	local w, h = width or 480, height or 270

	local flash_pixel = char(0, 0, 0, 0)
	local black_pixel = char(0, 0, 0, 220)

	local canvas = engine:canvas()

	return setmetatable({
		canvas = canvas,
		w = w,
		h = h,
		flash_pixel = flash_pixel,
		black_pixel = black_pixel,
		flashing = false,
		flash_sequence = {},
		flash_index = 0,
		next_flash = moment() + random(2000, 5000),
	}, self)
end

function Light:start_flash_sequence()
	local sequence = {}
	local now = moment()
	local t = now

	local flashes = random(3, 6)
	for _ = 1, flashes do
		local duration_on = random(100, 300)
		local duration_off = random(100, 300)
		sequence[#sequence + 1] = { time = t, on = true }
		t = t + duration_on
		sequence[#sequence + 1] = { time = t, on = false }
		t = t + duration_off
	end

	self.flash_sequence = sequence
	self.flash_index = 1
end

function Light:loop()
	local now = moment()

	if self.flash_sequence[self.flash_index] then
		local step = self.flash_sequence[self.flash_index]
		if now >= step.time then
			self.flashing = step.on
			self.flash_index = self.flash_index + 1
		end
	else
		if self.flash_index > 0 then
			self.flash_sequence = {}
			self.flash_index = 0
			self.next_flash = now + random(2000, 5000)
			self.flashing = false
		elseif now > self.next_flash then
			self:start_flash_sequence()
		end
	end

	if self.flashing then
		self.canvas.pixels = rep(self.flash_pixel, self.w * self.h)
		return
	end

	self.canvas.pixels = rep(self.black_pixel, self.w * self.h)
end

function Light:teardown() end

return Light:new()
