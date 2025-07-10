local NoiseEffect = {}
NoiseEffect.__index = NoiseEffect

local char, concat, floor = string.char, table.concat, math.floor

local seed = os.time()
local function random()
	seed = (1103515245 * seed + 12345) % 2147483648
	return seed
end

local function shuffle(mask)
	for i = #mask, 2, -1 do
		local j = random() % i + 1
		mask[i], mask[j] = mask[j], mask[i]
	end
end

function NoiseEffect:new(width, height, duration)
	local obj = {
		canvas = engine:canvas(),
		width = width or 480,
		height = height or 270,
		duration = duration or 1000,
		callback = nil,
		start_time = nil,
		pixel_count = (width or 480) * (height or 270),
		buffer = {},
		color_mask = {},
		cache = {
			black = {},
			white = {},
			color = {},
		},
	}
	return setmetatable(obj, self)
end

function NoiseEffect:init()
	self.start_time = moment()
end

function NoiseEffect:on_finish(cb)
	self.callback = cb
end

function NoiseEffect:loop()
	local now = moment()
	local elapsed = now - self.start_time
	local duration, total = self.duration, self.pixel_count
	local b, mask, cache = self.buffer, self.color_mask, self.cache

	if elapsed >= duration then
		local px = { char(0, 0, 0, 0), char(255, 255, 255, 0) }
		for i = 1, total do
			b[i] = px[(i % 2) + 1]
		end
		self.canvas.pixels = concat(b, "", 1, total)

		local cb = self.callback
		if cb then
			cb()
			self.callback = nil
		end
		return
	end

	local fade = 1 - (elapsed / duration)
	local half = floor(total / 2)
	for i = 1, total do
		mask[i] = (i <= half) and "black" or "white"
	end
	shuffle(mask)

	for i = 1, total do
		local use_color = (random() % 100) < 15
		local raw_a = random() % 241 + 10
		local a = floor(raw_a * fade)
		local px

		if use_color then
			local r = random() % 256
			local g = random() % 256
			local b = random() % 256
			local key = r * 16777216 + g * 65536 + b * 256 + a
			px = cache.color[key]
			if not px then
				px = char(r, g, b, a)
				cache.color[key] = px
			end
		else
			local base = mask[i]
			local set = cache[base]
			px = set[a]
			if not px then
				if base == "black" then
					px = char(0, 0, 0, a)
				else
					px = char(255, 255, 255, a)
				end
				set[a] = px
			end
		end
		b[i] = px
	end

	self.canvas.pixels = concat(b, "", 1, total)
end

function NoiseEffect:teardown() end

return NoiseEffect:new()
