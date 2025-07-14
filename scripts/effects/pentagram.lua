local Pentagram = {}
Pentagram.__index = Pentagram

local char, concat, floor, abs, cos, sin, pi =
	string.char, table.concat, math.floor, math.abs, math.cos, math.sin, math.pi

local RED_PIXEL = char(0, 0, 255, 255)

function Pentagram:new(width, height)
	local w, h = width or 480, height or 270
	local total = w * h
	return setmetatable({
		canvas = engine:canvas(),
		width = w,
		height = h,
		total = total,
		buffer = {},
		start_time = moment(),
		scale = h * 0.4,
		line_thickness = 2,
		edges = {
			{ 1, 3 },
			{ 3, 5 },
			{ 5, 2 },
			{ 2, 4 },
			{ 4, 1 },
		},
	}, self)
end

function Pentagram:init() end

function Pentagram:plot(x, y)
	if x < 0 or x >= self.width or y < 0 or y >= self.height then
		return
	end
	local idx = y * self.width + x + 1
	self.buffer[idx] = RED_PIXEL
end

function Pentagram:draw_thick_point(x, y)
	local t = self.line_thickness
	for dy = -t, t do
		for dx = -t, t do
			self:plot(x + dx, y + dy)
		end
	end
end

function Pentagram:draw_line(x0, y0, x1, y1)
	x0, y0 = floor(x0), floor(y0)
	x1, y1 = floor(x1), floor(y1)
	local dx, dy = abs(x1 - x0), abs(y1 - y0)
	local sx = (x0 < x1) and 1 or -1
	local sy = (y0 < y1) and 1 or -1
	local err = dx - dy

	while true do
		self:draw_thick_point(x0, y0)
		if x0 == x1 and y0 == y1 then
			return
		end
		local e2 = 2 * err
		if e2 > -dy then
			err = err - dy
			x0 = x0 + sx
		end
		if e2 < dx then
			err = err + dx
			y0 = y0 + sy
		end
	end
end

function Pentagram:draw_rotating_circle(cx, cy, radius, cos_y, sin_y)
	local segments = 360
	local angle_step = (2 * pi) / segments
	local prev_x, prev_y

	for i = 0, segments do
		local angle = i * angle_step
		local x, y, z = cos(angle), -sin(angle), 0
		local x_rot = x * cos_y - z * sin_y
		local z_rot = x * sin_y + z * cos_y
		local fov = 1 / (1 + z_rot * 0.5)
		local screen_x = cx + x_rot * radius * fov
		local screen_y = cy + y * radius * fov

		if prev_x then
			self:draw_line(prev_x, prev_y, screen_x, screen_y)
		end
		prev_x, prev_y = screen_x, screen_y
	end
end

function Pentagram:loop()
	local elapsed = (moment() - self.start_time) * 0.001
	local cos_y, sin_y = cos(elapsed * 0.8), sin(elapsed * 0.8)
	local cx, cy = self.width * 0.5, self.height * 0.5
	local projected = {}
	local angle_step = pi * 0.4
	local phase_offset = pi * 1.5

	for i = 1, self.total do
		self.buffer[i] = char(0, 0, 0, 0)
	end

	for i = 0, 4 do
		local angle = angle_step * i + phase_offset
		local x, y, z = cos(angle), -sin(angle), 0
		local x_rot = x * cos_y - z * sin_y
		local z_rot = x * sin_y + z * cos_y
		local fov = 1 / (1 + z_rot * 0.5)
		projected[i + 1] = {
			x = cx + x_rot * self.scale * fov,
			y = cy + y * self.scale * fov,
		}
	end

	for _, edge in ipairs(self.edges) do
		local a, b = projected[edge[1]], projected[edge[2]]
		self:draw_line(a.x, a.y, b.x, b.y)
	end

	self:draw_rotating_circle(cx, cy, self.scale, cos_y, sin_y)
	self.canvas.pixels = concat(self.buffer, "", 1, self.total)
end

function Pentagram:teardown()
	for i = 1, self.total do
		self.buffer[i] = char(0, 0, 0, 0)
	end
	self.canvas.pixels = concat(self.buffer, "", 1, self.total)
end

return Pentagram:new()
