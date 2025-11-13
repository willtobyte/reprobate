local M = {}
M.__index = M

local char = string.char
local concat = table.concat
local floor = math.floor
local sin = math.sin
local cos = math.cos
local abs = math.abs
local rep = string.rep

local WIDTH = 480
local HEIGHT = 270
local BUFFER_SIZE = 129600

local RED_PIXEL = char(255, 0, 0, 255)
local TRANSPARENT_PIXEL = char(0, 0, 0, 0)

local pentagram_radius = 90
local PENT_VERTS = {}

for i = 0, 4 do
  local angle = i * 1.2566370614359172 + 1.5707963267948966
  local idx = i * 3
  PENT_VERTS[idx + 1] = cos(angle) * pentagram_radius
  PENT_VERTS[idx + 2] = sin(angle) * pentagram_radius
  PENT_VERTS[idx + 3] = 0
end

local CIRC_VERTS = {}
local circle_segments = 24

for i = 0, 23 do
  local angle = i * 0.26179938779914946
  local idx = i * 3
  CIRC_VERTS[idx + 1] = cos(angle) * 90
  CIRC_VERTS[idx + 2] = sin(angle) * 90
  CIRC_VERTS[idx + 3] = 0
end

local PENT_EDGES = { 1, 3, 3, 5, 5, 2, 2, 4, 4, 1 }
local CIRC_EDGES = {
  1,
  2,
  2,
  3,
  3,
  4,
  4,
  5,
  5,
  6,
  6,
  7,
  7,
  8,
  8,
  9,
  9,
  10,
  10,
  11,
  11,
  12,
  12,
  13,
  13,
  14,
  14,
  15,
  15,
  16,
  16,
  17,
  17,
  18,
  18,
  19,
  19,
  20,
  20,
  21,
  21,
  22,
  22,
  23,
  23,
  24,
  24,
  1,
}

local function draw_line(pixels, x0, y0, x1, y1)
  local dx = abs(x1 - x0)
  local dy = abs(y1 - y0)
  local sx = x0 < x1 and 1 or -1
  local sy = y0 < y1 and 1 or -1
  local err = dx - dy
  local x, y = x0, y0

  for _ = 1, dx + dy + 1 do
    if y > 0 and y < 269 and x > 0 and x < 479 then
      local idx = y * 480 + x + 1
      pixels[idx] = 1
      pixels[idx - 1] = 1
      pixels[idx + 1] = 1
      pixels[idx - 480] = 1
      pixels[idx + 480] = 1
      pixels[idx - 481] = 1
      pixels[idx - 479] = 1
      pixels[idx + 479] = 1
      pixels[idx + 481] = 1
    end

    if x == x1 and y == y1 then
      break
    end

    local e2 = err + err
    if e2 > -dy then
      err = err - dy
      x = x + sx
    end
    if e2 < dx then
      err = err + dx
      y = y + sy
    end
  end
end

function M:new()
  local obj = setmetatable({
    w = WIDTH,
    h = HEIGHT,
    angle = 0,
    last_update = moment(),
    rotation_speed = 0.4,
    buf = {},
    pp = {},
    pc = {},
  }, self)

  for i = 1, BUFFER_SIZE do
    obj.buf[i] = 0
  end

  for i = 1, 10 do
    obj.pp[i] = 0
  end

  for i = 1, 48 do
    obj.pc[i] = 0
  end

  return obj
end

function M:loop()
  local pixels = self.buf
  local pp = self.pp
  local pc = self.pc

  local current = moment()
  local delta = (current - self.last_update) * 0.001
  self.last_update = current

  for i = 1, BUFFER_SIZE do
    pixels[i] = 0
  end

  local angle = self.angle
  local ca = cos(angle)
  local sa = sin(angle)

  for i = 0, 4 do
    local idx = i * 3
    local x = PENT_VERTS[idx + 1]
    local z = PENT_VERTS[idx + 3]

    local rx = x * ca + z * sa
    local rz = -x * sa + z * ca

    local scale = 0.8571428571428571 / (1 - rz * 0.0028571428571428571)
    local pidx = i * 2
    pp[pidx + 1] = floor(240 + rx * scale)
    pp[pidx + 2] = floor(135 + PENT_VERTS[idx + 2] * scale)
  end

  for i = 0, 23 do
    local idx = i * 3
    local x = CIRC_VERTS[idx + 1]
    local z = CIRC_VERTS[idx + 3]

    local rx = x * ca + z * sa
    local rz = -x * sa + z * ca

    local scale = 0.8571428571428571 / (1 - rz * 0.0028571428571428571)
    local pidx = i * 2
    pc[pidx + 1] = floor(240 + rx * scale)
    pc[pidx + 2] = floor(135 + CIRC_VERTS[idx + 2] * scale)
  end

  for i = 1, 48, 2 do
    local idx0 = (CIRC_EDGES[i] - 1) * 2
    local idx1 = (CIRC_EDGES[i + 1] - 1) * 2
    draw_line(pixels, pc[idx0 + 1], pc[idx0 + 2], pc[idx1 + 1], pc[idx1 + 2])
  end

  for i = 1, 10, 2 do
    local idx0 = (PENT_EDGES[i] - 1) * 2
    local idx1 = (PENT_EDGES[i + 1] - 1) * 2
    draw_line(pixels, pp[idx0 + 1], pp[idx0 + 2], pp[idx1 + 1], pp[idx1 + 2])
  end

  local parts = {}
  local part_count = 0
  local i = 1

  while i <= BUFFER_SIZE do
    local v = pixels[i]
    local j = i + 1

    while j <= BUFFER_SIZE and pixels[j] == v do
      j = j + 1
    end

    part_count = part_count + 1
    parts[part_count] = v == 1 and rep(RED_PIXEL, j - i) or rep(TRANSPARENT_PIXEL, j - i)
    i = j
  end

  canvas.pixels = concat(parts)

  self.angle = self.angle + self.rotation_speed * delta
  if self.angle >= 6.283185307179586 then
    self.angle = self.angle - 6.283185307179586
  end
end

function M:teardown()
  self.buf = nil
  self.pp = nil
  self.pc = nil
  canvas:clear()
end

return M:new()
