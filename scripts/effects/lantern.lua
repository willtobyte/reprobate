local lantern = {}
lantern.__index = lantern

local char, concat, floor = string.char, table.concat, math.floor

local radius = 40
local fade = 20
local total_radius = radius + fade
local max_d2 = total_radius * total_radius
local min_d2 = radius * radius

local levels = 6
local level_step = (max_d2 - min_d2) / levels

local function random_alpha_offset()
	return math.random(0, 40) - 20
end

function lantern:new(width, height)
	local w, h = width or 480, height or 270
	local total = w * h
	local cache = {}
	for i = 0, 255 do
		cache[i] = char(0, 0, 0, i)
	end
	return setmetatable({
		canvas = engine:canvas(),
		width = w,
		height = h,
		total = total,
		buffer = {},
		mx = floor(w * 0.5),
		my = floor(h * 0.5),
		alpha_cache = cache,
	}, self)
end

function lantern:motion(x, y)
	self.mx = floor(x)
	self.my = floor(y)
end

function lantern:loop()
	local w, h = self.width, self.height
	local mx, my = self.mx, self.my
	local buf = self.buffer
	local cache = self.alpha_cache

	for y = 0, h - 1 do
		for x = 0, w - 1 do
			local dx = x - mx
			local dy = y - my
			local d2 = dx * dx + dy * dy
			local i = y * w + x + 1

			if d2 <= min_d2 then
				buf[i] = cache[0]
			elseif d2 >= max_d2 then
				buf[i] = cache[255]
			else
				local layer = floor((d2 - min_d2) / level_step)
				local base_alpha = floor((layer / (levels - 1)) * 255)
				local a = base_alpha + random_alpha_offset()
				if a < 0 then
					a = 0
				elseif a > 255 then
					a = 255
				end
				buf[i] = cache[a]
			end
		end
	end

	self.canvas.pixels = concat(buf, "", 1, self.total)
end

function lantern:teardown()
	local buf = self.buffer
	local px = self.alpha_cache[255]
	for i = 1, self.total do
		buf[i] = px
	end
	self.canvas.pixels = concat(buf, "", 1, self.total)
end

return lantern:new()
