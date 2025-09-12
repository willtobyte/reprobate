local Pentagram = {}
Pentagram.__index = Pentagram

local char = string.char
local concat = table.concat
local floor = math.floor
local abs = math.abs
local cos = math.cos
local sin = math.sin
local pi = math.pi

local COLOR_PIXEL = char(255, 0, 0, 0)
local BLANK_PIXEL = char(0, 0, 0, 0)

function Pentagram:new(width, height)
  local w = width or 480
  local h = height or 270
  local total = w * h

  local buffer = {}
  for i = 1, total do
    buffer[i] = BLANK_PIXEL
  end

  local segments = 360
  local angle_step = (2 * pi) / segments
  local unit_circle = {}
  for i = 1, segments do
    local ang = (i - 1) * angle_step
    unit_circle[i] = { cos(ang), -sin(ang) }
  end

  local cyclic_step = pi * 0.4
  local phase_offset = pi * 1.5
  local pent_angles = {}
  for i = 1, 5 do
    pent_angles[i] = cyclic_step * (i - 1) + phase_offset
  end
  local edges = { { 1, 3 }, { 3, 5 }, { 5, 2 }, { 2, 4 }, { 4, 1 } }

  local t = 3

  return setmetatable({
    canvas = engine:canvas(),
    w = w,
    h = h,
    total = total,
    buffer = buffer,
    start_time = moment(),
    scale = h * 0.4,
    segments = segments,
    unit_circle = unit_circle,
    pent_angles = pent_angles,
    edges = edges,
    thickness = t,
    RED = COLOR_PIXEL,
    BLANK = BLANK_PIXEL,
    callback = nil,
    finished = false,
  }, self)
end

function Pentagram:on_finish(fn)
  self.callback = fn
end

function Pentagram:loop()
  local w, h, total = self.w, self.h, self.total
  local buf = self.buffer
  local BLANK = self.BLANK
  local unit_circle = self.unit_circle
  local pent_angles = self.pent_angles
  local edges = self.edges
  local t = self.thickness
  local scale = self.scale
  local segs = self.segments
  local now = moment()

  if not self.alpha_start then
    self.alpha_start = now
  end

  for i = 1, total do
    buf[i] = BLANK
  end

  local elapsed = (now - self.start_time) * 0.001
  local a_elapsed = (now - self.alpha_start) * 0.001
  local a = a_elapsed >= 6 and 255 or floor((a_elapsed / 6) * 255)
  self.RED = char(255, 0, 0, a)
  local RED = self.RED

  if a == 255 and not self.finished then
    self.finished = true
    if self.callback then
      self.callback()
    end
  end

  local cos_y = cos(elapsed * 0.8)
  local sin_y = sin(elapsed * 0.8)
  local cx, cy = w * 0.5, h * 0.5

  local proj = {}
  for i = 1, 5 do
    local ang = pent_angles[i]
    local x0 = cos(ang)
    local z0 = 0
    local x_r = x0 * cos_y - z0 * sin_y
    local z_r = x0 * sin_y + z0 * cos_y
    local fov = 1 / (1 + z_r * 0.5)
    proj[i] = {
      x = cx + x_r * scale * fov,
      y = cy - sin(ang) * scale * fov,
    }
  end

  local w_mul = w
  for _, e in ipairs(edges) do
    local a = proj[e[1]]
    local b = proj[e[2]]
    local x0 = floor(a.x)
    local y0 = floor(a.y)
    local x1 = floor(b.x)
    local y1 = floor(b.y)
    local dx = abs(x1 - x0)
    local dy = abs(y1 - y0)
    local sx = x0 < x1 and 1 or -1
    local sy = y0 < y1 and 1 or -1
    local err = dx - dy
    while true do
      for dy_off = -t, t do
        local yy = y0 + dy_off
        if yy >= 0 and yy < h then
          local base = yy * w_mul
          for dx_off = -t, t do
            local xx = x0 + dx_off
            if xx >= 0 and xx < w then
              buf[base + xx + 1] = RED
            end
          end
        end
      end
      if x0 == x1 and y0 == y1 then
        break
      end
      local e2 = err * 2
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

  for i = 1, segs do
    local u = unit_circle[i]
    local x0, y0 = u[1], u[2]
    local x_r = x0 * cos_y
    local z_r = x0 * sin_y
    local fov0 = 1 / (1 + z_r * 0.5)
    local sx0 = cx + x_r * scale * fov0
    local sy0 = cy + y0 * scale * fov0

    local j = (i % segs) + 1
    local u2 = unit_circle[j]
    local x1u, y1u = u2[1], u2[2]
    local x1_r = x1u * cos_y
    local z1_r = x1u * sin_y
    local fov1 = 1 / (1 + z1_r * 0.5)
    local sx1 = cx + x1_r * scale * fov1
    local sy1 = cy + y1u * scale * fov1

    local xi0 = floor(sx0)
    local yi0 = floor(sy0)
    local xi1 = floor(sx1)
    local yi1 = floor(sy1)
    local dx = abs(xi1 - xi0)
    local dy = abs(yi1 - yi0)
    local sx = xi0 < xi1 and 1 or -1
    local sy = yi0 < yi1 and 1 or -1
    local err = dx - dy
    while true do
      for dy_off = -t, t do
        local yy = yi0 + dy_off
        if yy >= 0 and yy < h then
          local base = yy * w_mul
          for dx_off = -t, t do
            local xx = xi0 + dx_off
            if xx >= 0 and xx < w then
              buf[base + xx + 1] = RED
            end
          end
        end
      end
      if xi0 == xi1 and yi0 == yi1 then
        break
      end
      local e2 = err * 2
      if e2 > -dy then
        err = err - dy
        xi0 = xi0 + sx
      end
      if e2 < dx then
        err = err + dx
        yi0 = yi0 + sy
      end
    end
  end

  self.canvas.pixels = concat(buf, "", 1, total)
end

function Pentagram:teardown()
  for i = 1, self.total do
    self.buffer[i] = BLANK_PIXEL
  end
  self.canvas.pixels = concat(self.buffer, "", 1, self.total)
end

return Pentagram:new()
