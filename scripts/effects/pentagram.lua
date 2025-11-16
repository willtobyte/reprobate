local M = {}
M.__index = M

local char = string.char
local concat = table.concat
local rep = string.rep
local floor = math.floor
local sin = math.sin
local cos = math.cos
local abs = math.abs

local WIDTH = 480
local HEIGHT = 270
local CENTER_X = 240
local CENTER_Y = 135
local BUFFER_SIZE = 129600
local PI2 = 6.283185307179586

local RED_PIXEL = char(255, 0, 0, 255)
local TRANSPARENT_PIXEL = char(0, 0, 0, 0)

local TRANSPARENT_ROW = rep(TRANSPARENT_PIXEL, WIDTH)

local PENTAGRAM_RADIUS = 90
local PV = {}
for i = 0, 4 do
  local angle = i * 1.2566370614359172 + 1.5707963267948966
  PV[i * 3 + 1] = cos(angle) * PENTAGRAM_RADIUS
  PV[i * 3 + 2] = sin(angle) * PENTAGRAM_RADIUS
  PV[i * 3 + 3] = 0
end

local CIRCLE_RADIUS = 90
local CV = {}
for i = 0, 23 do
  local angle = i * 0.26179938779914946
  CV[i * 3 + 1] = cos(angle) * CIRCLE_RADIUS
  CV[i * 3 + 2] = sin(angle) * CIRCLE_RADIUS
  CV[i * 3 + 3] = 0
end

local PE = { 1, 3, 3, 5, 5, 2, 2, 4, 4, 1 }

local CE = {
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

local buffer = {}
local pp = {}
local pc = {}

for i = 1, BUFFER_SIZE do
  buffer[i] = 0
end

for i = 1, 10 do
  pp[i] = 0
end

for i = 1, 48 do
  pc[i] = 0
end

local function draw_line(buf, x0, y0, x1, y1)
  if (x0 < -5 or x0 > 485 or y0 < -5 or y0 > 275) and (x1 < -5 or x1 > 485 or y1 < -5 or y1 > 275) then
    return
  end

  local dx = abs(x1 - x0)
  local dy = abs(y1 - y0)
  local sx = x0 < x1 and 1 or -1
  local sy = y0 < y1 and 1 or -1
  local err = dx - dy
  local x, y = x0, y0

  while true do
    if y >= 1 and y < 269 and x >= 1 and x < 479 then
      local idx = y * 480 + x + 1

      buf[idx] = 1
      buf[idx - 1] = 1
      buf[idx + 1] = 1
      buf[idx - 480] = 1
      buf[idx + 480] = 1
      buf[idx - 481] = 1
      buf[idx - 479] = 1
      buf[idx + 479] = 1
      buf[idx + 481] = 1
    end

    if x == x1 and y == y1 then
      break
    end

    local e2 = err * 2
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
  return setmetatable({
    w = WIDTH,
    h = HEIGHT,
    angle = 0,
    rotation_speed = 0.8,
  }, self)
end

function M:loop(delta)
  for i = 1, BUFFER_SIZE do
    buffer[i] = 0
  end

  local angle = self.angle
  local ca = cos(angle)
  local sa = sin(angle)

  local x0, z0 = PV[1], PV[3]
  local rx0 = x0 * ca + z0 * sa
  local rz0 = -x0 * sa + z0 * ca
  local sc0 = 0.8571428571428571 / (1 - rz0 * 0.0028571428571428571)
  pp[1] = floor(240 + rx0 * sc0)
  pp[2] = floor(135 + PV[2] * sc0)

  local x1, z1 = PV[4], PV[6]
  local rx1 = x1 * ca + z1 * sa
  local rz1 = -x1 * sa + z1 * ca
  local sc1 = 0.8571428571428571 / (1 - rz1 * 0.0028571428571428571)
  pp[3] = floor(240 + rx1 * sc1)
  pp[4] = floor(135 + PV[5] * sc1)

  local x2, z2 = PV[7], PV[9]
  local rx2 = x2 * ca + z2 * sa
  local rz2 = -x2 * sa + z2 * ca
  local sc2 = 0.8571428571428571 / (1 - rz2 * 0.0028571428571428571)
  pp[5] = floor(240 + rx2 * sc2)
  pp[6] = floor(135 + PV[8] * sc2)

  local x3, z3 = PV[10], PV[12]
  local rx3 = x3 * ca + z3 * sa
  local rz3 = -x3 * sa + z3 * ca
  local sc3 = 0.8571428571428571 / (1 - rz3 * 0.0028571428571428571)
  pp[7] = floor(240 + rx3 * sc3)
  pp[8] = floor(135 + PV[11] * sc3)

  local x4, z4 = PV[13], PV[15]
  local rx4 = x4 * ca + z4 * sa
  local rz4 = -x4 * sa + z4 * ca
  local sc4 = 0.8571428571428571 / (1 - rz4 * 0.0028571428571428571)
  pp[9] = floor(240 + rx4 * sc4)
  pp[10] = floor(135 + PV[14] * sc4)

  for i = 0, 23 do
    local idx = i * 3
    local x, z = CV[idx + 1], CV[idx + 3]
    local rx = x * ca + z * sa
    local rz = -x * sa + z * ca
    local sc = 0.8571428571428571 / (1 - rz * 0.0028571428571428571)
    local pi = i * 2
    pc[pi + 1] = floor(240 + rx * sc)
    pc[pi + 2] = floor(135 + CV[idx + 2] * sc)
  end

  for i = 1, 48, 2 do
    local i0 = (CE[i] - 1) * 2
    local i1 = (CE[i + 1] - 1) * 2
    draw_line(buffer, pc[i0 + 1], pc[i0 + 2], pc[i1 + 1], pc[i1 + 2])
  end

  draw_line(buffer, pp[1], pp[2], pp[5], pp[6])
  draw_line(buffer, pp[5], pp[6], pp[9], pp[10])
  draw_line(buffer, pp[9], pp[10], pp[3], pp[4])
  draw_line(buffer, pp[3], pp[4], pp[7], pp[8])
  draw_line(buffer, pp[7], pp[8], pp[1], pp[2])

  local parts = {}
  local pcount = 0
  local i = 1

  while i <= BUFFER_SIZE do
    local val = buffer[i]
    local start = i

    repeat
      i = i + 1
    until i > BUFFER_SIZE or buffer[i] ~= val

    local len = i - start

    pcount = pcount + 1
    if val == 1 then
      parts[pcount] = rep(RED_PIXEL, len)
    else
      if len == WIDTH then
        parts[pcount] = TRANSPARENT_ROW
      elseif len >= WIDTH * 2 then
        local rows = floor(len / WIDTH)
        local remainder = len - rows * WIDTH
        if rows > 1 then
          pcount = pcount + 1
          parts[pcount - 1] = rep(TRANSPARENT_ROW, rows)
          parts[pcount] = remainder > 0 and rep(TRANSPARENT_PIXEL, remainder) or ""
        else
          parts[pcount] = TRANSPARENT_ROW
          if remainder > 0 then
            pcount = pcount + 1
            parts[pcount] = rep(TRANSPARENT_PIXEL, remainder)
          end
        end
      else
        parts[pcount] = rep(TRANSPARENT_PIXEL, len)
      end
    end
  end

  canvas.pixels = concat(parts)

  self.angle = self.angle + self.rotation_speed * delta
  if self.angle >= PI2 then
    self.angle = self.angle - PI2
  end
end

function M:teardown()
  for i = 1, BUFFER_SIZE do
    buffer[i] = nil
  end

  for i = 1, 10 do
    pp[i] = nil
  end

  for i = 1, 48 do
    pc[i] = nil
  end

  canvas:clear()
end

return M:new()
