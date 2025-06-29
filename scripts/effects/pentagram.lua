local ALPHA_MASK = 0xFF000000
local RED_COLOR = 0xFF0000

local Pentagram = {}
Pentagram.__index = Pentagram

function Pentagram:new(width, height)
  local self = setmetatable({}, Pentagram)

  self.canvas = engine:canvas()
  self.width = width or 480
  self.height = height or 270
  self.pixels = {}

  self.pi = math.pi
  self.cos = math.cos
  self.sin = math.sin
  self.floor = math.floor
  self.abs = math.abs

  self.start_time = moment()
  self.scale = self.height * 0.4
  self.line_thickness = 2

  self.edges = {
    { 1, 3 },
    { 3, 5 },
    { 5, 2 },
    { 2, 4 },
    { 4, 1 },
  }

  return self
end

function Pentagram:init() end

function Pentagram:plot(x, y)
  if x >= 0 and x < self.width and y >= 0 and y < self.height then
    local index = y * self.width + x + 1
    self.pixels[index] = ALPHA_MASK + RED_COLOR
  end
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
  x0 = self.floor(x0)
  y0 = self.floor(y0)
  x1 = self.floor(x1)
  y1 = self.floor(y1)

  local dx = self.abs(x1 - x0)
  local dy = self.abs(y1 - y0)
  local sx = x0 < x1 and 1 or -1
  local sy = y0 < y1 and 1 or -1
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
  local angle_step = (2 * self.pi) / segments
  local prev_x, prev_y

  for i = 0, segments do
    local angle = i * angle_step
    local x = self.cos(angle)
    local y = -self.sin(angle)
    local z = 0

    local x_rot = x * cos_y - z * sin_y
    local z_rot = x * sin_y + z * cos_y

    local fov = 1 / (1 + z_rot * 0.5)
    local screen_x = cx + x_rot * radius * fov
    local screen_y = cy + y * radius * fov

    if prev_x and prev_y then
      self:draw_line(prev_x, prev_y, screen_x, screen_y)
    end

    prev_x, prev_y = screen_x, screen_y
  end
end

function Pentagram:loop()
  local elapsed = (moment() - self.start_time) * 0.001
  local angle_y = elapsed * 0.8

  local cos_y = self.cos(angle_y)
  local sin_y = self.sin(angle_y)

  local cx = self.width * 0.5
  local cy = self.height * 0.5
  local projected = {}
  local angle_step = self.pi * 0.4
  local phase_offset = self.pi * 1.5

  for i = 0, 4 do
    local angle = angle_step * i + phase_offset
    local x = self.cos(angle)
    local y = -self.sin(angle)
    local z = 0

    local x_rot = x * cos_y - z * sin_y
    local z_rot = x * sin_y + z * cos_y
    local fov = 1 / (1 + z_rot * 0.5)

    projected[i + 1] = {
      x = cx + x_rot * self.scale * fov,
      y = cy + y * self.scale * fov,
    }
  end

  for i = 1, self.width * self.height do
    self.pixels[i] = 0x00000000
  end

  for _, edge in ipairs(self.edges) do
    local a = projected[edge[1]]
    local b = projected[edge[2]]
    self:draw_line(a.x, a.y, b.x, b.y)
  end

  self:draw_rotating_circle(cx, cy, self.scale, cos_y, sin_y)

  self.canvas.pixels = self.pixels
end

function Pentagram:teardown()
  for i = 1, self.width * self.height do
    self.pixels[i] = 0x00000000
  end
  self.canvas.pixels = self.pixels
end

return Pentagram:new()
