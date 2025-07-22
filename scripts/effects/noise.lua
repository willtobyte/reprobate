local NoiseEffect = {}
NoiseEffect.__index = NoiseEffect

local char, concat, floor, min, sqrt = string.char, table.concat, math.floor, math.min, math.sqrt

local seed = os.time()
local function random()
	seed = (1103515245 * seed + 12345) % 2147483648
	return seed
end

function NoiseEffect:new(width, height, duration, rect_n)
	local w, h = width or 480, height or 270
	local rn = rect_n or 280
	local sb = sqrt(700 / rn)
	return setmetatable({
		canvas = engine:canvas(),
		width = w,
		height = h,
		duration = duration or 2000,
		start_time = nil,
		callback = nil,
		pixel_count = w * h,
		buffer = {},
		cache = {},
		done = false,
		rect_n = rn,
		size_boost = sb,
	}, self)
end

function NoiseEffect:init()
	self.start_time = moment()
end

function NoiseEffect:on_finish(cb)
	self.callback = cb
end

local function fill_block(buffer, width, height, x, y, bw, bh, px)
	for dy = 0, bh - 1 do
		local row = y + dy
		if row >= height then
			break
		end
		for dx = 0, bw - 1 do
			local col = x + dx
			if col >= width then
				break
			end
			local idx = row * width + col + 1
			buffer[idx] = px
		end
	end
end

function NoiseEffect:loop()
	if self.done then
		return
	end

	local now = moment()
	local elapsed = now - self.start_time
	local duration = self.duration
	local w = self.width
	local h = self.height
	local total = self.pixel_count
	local buffer = self.buffer
	local cache = self.cache

	if elapsed >= duration then
		for i = 1, total do
			buffer[i] = char(0, 0, 0, 0)
		end
		self.canvas.pixels = concat(buffer, "", 1, total)
		if self.callback then
			self.callback()
			self.callback = nil
		end
		self.done = true
		return
	end

	local fade = 1 - (elapsed / duration)
	local alpha = floor(255 * fade)

	for i = 1, total do
		local r = random() % 256
		local g = random() % 256
		local b = random() % 256
		local key = r * 16777216 + g * 65536 + b * 256 + alpha
		local px = cache[key]
		if not px then
			px = char(r, g, b, alpha)
			cache[key] = px
		end
		buffer[i] = px
	end

	local rect_n = self.rect_n
	local sb = self.size_boost
	local max_bw = floor(24 * sb)
	local max_bh = floor(10 * sb)

	for _ = 1, rect_n do
		local bw = 2 + (random() % max_bw)
		local bh = 1 + (random() % max_bh)

		bw = min(bw, w)
		bh = min(bh, h)

		local x = random() % (w - bw)
		local y = random() % (h - bh)

		local r = random() % 256
		local g = random() % 256
		local b = random() % 256
		local a = floor(alpha * (0.3 + (random() % 71) / 100))

		local key = r * 16777216 + g * 65536 + b * 256 + a
		local px = cache[key]
		if not px then
			px = char(r, g, b, a)
			cache[key] = px
		end

		fill_block(buffer, w, h, x, y, bw, bh, px)
	end

	for i = 1, 20 do
		local y = random() % h
		local a = floor(alpha * (0.3 + (random() % 71) / 100))
		local r = random() % 256
		local g = random() % 256
		local b = random() % 256
		local key = r * 16777216 + g * 65536 + b * 256 + a
		local px = cache[key]
		if not px then
			px = char(r, g, b, a)
			cache[key] = px
		end
		fill_block(buffer, w, h, 0, y, w, 1, px)
	end

	for _ = 1, 40 do
		local x = random() % w
		local y = random() % h
		local len = 10 + (random() % 40)
		local a = floor(alpha * (0.3 + (random() % 71) / 100))
		local r = random() % 256
		local g = random() % 256
		local b = random() % 256
		local key = r * 16777216 + g * 65536 + b * 256 + a
		local px = cache[key]
		if not px then
			px = char(r, g, b, a)
			cache[key] = px
		end

		for i = 0, len do
			local dx = (x + i) % w
			local dy = (y + i) % h
			local idx = dy * w + dx + 1
			buffer[idx] = px
		end
	end

	self.canvas.pixels = concat(buffer, "", 1, total)
end

function NoiseEffect:teardown() end

return NoiseEffect:new()
