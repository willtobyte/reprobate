local Lantern = {}
Lantern.__index = Lantern

local char, concat, floor = string.char, table.concat, math.floor
local rep = string.rep

local radius = 40
local fade = 20
local total_radius = radius + fade
local max_d2 = total_radius * total_radius
local min_d2 = radius * radius
local levels = 6
local level_step = (max_d2 - min_d2) / levels

function Lantern:new(width, height)
	local w = width or 480
	local h = height or 270

	local cache = {}
	for i = 0, 255 do
		cache[i] = char(0, 0, 0, i)
	end

	local alpha_map = {}
	for d2 = 0, max_d2 do
		if d2 <= min_d2 then
			alpha_map[d2] = 0
		elseif d2 < max_d2 then
			local layer = floor((d2 - min_d2) / level_step)
			alpha_map[d2] = floor((layer / (levels - 1)) * 255)
		else
			alpha_map[d2] = 255
		end
	end

	local dx2 = {}
	for x = 0, w - 1 do
		dx2[x] = 0
	end
	local dy2 = {}
	for y = 0, h - 1 do
		dy2[y] = 0
	end
	local dynamic_rows = {}

	local opaque_pixel = cache[255]
	local opaque_line = rep(opaque_pixel, w)
	return setmetatable({
		canvas = engine:canvas(),
		w = w,
		h = h,
		cache = cache,
		alpha_map = alpha_map,
		dx2 = dx2,
		dy2 = dy2,
		dynamic_rows = dynamic_rows,
		opaque_pixel = opaque_pixel,
		opaque_line = opaque_line,
		mx = floor(w * 0.5),
		my = floor(h * 0.5),
	}, self)
end

function Lantern:motion(x, y)
	self.mx = floor(x)
	self.my = floor(y)
end

function Lantern:loop()
	local w, h = self.w, self.h
	local mx, my = self.mx, self.my
	local cache, alpha_map = self.cache, self.alpha_map
	local dx2, dy2 = self.dx2, self.dy2
	local dynamic_rows = self.dynamic_rows
	local opaque_pixel, opaque_line = self.opaque_pixel, self.opaque_line

	for x = 0, w - 1 do
		local d = x - mx
		dx2[x] = d * d
	end
	for y = 0, h - 1 do
		local d = y - my
		dy2[y] = d * d
	end

	local y0 = my - total_radius
	if y0 < 0 then
		y0 = 0
	elseif y0 > h - 1 then
		y0 = h - 1
	end
	local y1 = my + total_radius
	if y1 > h - 1 then
		y1 = h - 1
	elseif y1 < 0 then
		y1 = 0
	end
	local x0 = mx - total_radius
	if x0 < 0 then
		x0 = 0
	elseif x0 > w - 1 then
		x0 = w - 1
	end
	local x1 = mx + total_radius
	if x1 > w - 1 then
		x1 = w - 1
	elseif x1 < 0 then
		x1 = 0
	end

	local dynW = x1 - x0 + 1
	local dynH = y1 - y0 + 1

	local prefix = rep(opaque_pixel, x0)
	local suffix = rep(opaque_pixel, w - (x1 + 1))

	for row = 1, dynH do
		local yi = y0 + row - 1
		local ddy = dy2[yi]
		local buf = {}
		for col = 1, dynW do
			local xi = x0 + col - 1
			local d2 = dx2[xi] + ddy
			if d2 > max_d2 then
				d2 = max_d2
			end
			local a0 = alpha_map[d2]
			buf[col] = cache[a0]
		end
		dynamic_rows[row] = prefix .. concat(buf, "", 1, dynW) .. suffix
	end

	local top = y0
	local bot = h - (y0 + dynH)
	local parts = {}
	if top > 0 then
		parts[#parts + 1] = rep(opaque_line, top)
	end
	if dynH > 0 then
		parts[#parts + 1] = concat(dynamic_rows, "", 1, dynH)
	end
	if bot > 0 then
		parts[#parts + 1] = rep(opaque_line, bot)
	end

	self.canvas.pixels = concat(parts, "")
end

function Lantern:teardown()
	self.canvas.pixels = rep(self.opaque_line, self.h)
end

return Lantern:new()
