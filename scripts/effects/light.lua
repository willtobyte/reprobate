local Light = {}
Light.__index = Light

local char, rep, random, moment = string.char, string.rep, math.random, moment

function Light:new(width, height)
	local w, h = width or 480, height or 270
	local canvas = engine:canvas()
	local self = setmetatable({
		canvas = canvas,
		w = w,
		h = h,
		light_mask = {},
		flashing = false,
		flash_sequence = {},
		flash_index = 0,
		next_flash = moment() + random(4000, 6000),
	}, Light)

	self:_generate_light_mask()
	return self
end

function Light:_generate_light_mask()
	local w, h = self.w, self.h
	local mask = {}
	local center_x = math.floor(w / 2)
	local start_width = 24
	local max_half_width = math.floor(w / 2)
	local delta = (max_half_width - math.floor(start_width / 2)) / h

	for y = 0, h - 1 do
		local half_width = math.floor(start_width / 2 + delta * y)
		local left = center_x - half_width
		local right = center_x + half_width

		for x = 0, w - 1 do
			local index = y * w + x + 1
			if x >= left and x <= right then
				local alpha = 50 + math.floor(170 * math.abs((x - center_x) / half_width))
				mask[index] = char(0, 0, 0, alpha)
			else
				mask[index] = char(0, 0, 0, 220)
			end
		end
	end

	self.light_mask = table.concat(mask)
end

function Light:start_flash_sequence()
	local now = moment()
	local sequence = {}
	local t = now

	local flashes = random(2, 3)
	for _ = 1, flashes do
		local duration_on = 100
		local duration_off = math.floor(random(1000, 3000) / 500) * 100

		sequence[#sequence + 1] = { time = t, on = true }
		t = t + duration_on

		sequence[#sequence + 1] = { time = t, on = false }
		t = t + duration_off
	end

	self.flash_sequence = sequence
	self.flash_index = 1
	self.next_flash = now + random(4000, 6000)
end

function Light:loop()
	local now = moment()

	local step = self.flash_sequence[self.flash_index]
	if step and now >= step.time then
		self.flashing = step.on
		self.flash_index = self.flash_index + 1
	elseif not step and self.flash_index > 0 then
		self.flash_sequence = {}
		self.flash_index = 0
		self.flashing = false
	elseif now >= self.next_flash and self.flash_index == 0 then
		self:start_flash_sequence()
	end

	if self.flashing then
		self.canvas.pixels = self.light_mask
		return
	end

	self.canvas.pixels = rep(char(0, 0, 0, 220), self.w * self.h)
end

function Light:teardown() end

return Light:new()
