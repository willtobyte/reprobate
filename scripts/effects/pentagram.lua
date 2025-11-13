local M = {}
M.__index = M

local c = string.char
local t = table.concat
local f = math.floor
local s = math.sin
local co = math.cos
local a = math.abs
local r = string.rep

local W = 480
local H = 270
local CX = 240
local CY = 135
local BS = 129600

local RP = c(255, 0, 0, 255)
local TP = c(0, 0, 0, 0)

local pr = 90
local PV = {}

for i = 0, 4 do
  local an = i * 1.2566370614359172 + 1.5707963267948966
  local ix = i * 3
  PV[ix + 1] = co(an) * pr
  PV[ix + 2] = s(an) * pr
  PV[ix + 3] = 0
end

local CV = {}
local cs = 24

for i = 0, 23 do
  local an = i * 0.26179938779914946
  local ix = i * 3
  CV[ix + 1] = co(an) * 90
  CV[ix + 2] = s(an) * 90
  CV[ix + 3] = 0
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

local function dl(p, x0, y0, x1, y1)
  local dx = a(x1 - x0)
  local dy = a(y1 - y0)
  local sx = x0 < x1 and 1 or -1
  local sy = y0 < y1 and 1 or -1
  local e = dx - dy
  local x, y = x0, y0

  for _ = 1, dx + dy + 1 do
    if y > 0 and y < 269 and x > 0 and x < 479 then
      local ix = y * 480 + x + 1
      p[ix] = 1
      p[ix - 1] = 1
      p[ix + 1] = 1
      p[ix - 480] = 1
      p[ix + 480] = 1
      p[ix - 481] = 1
      p[ix - 479] = 1
      p[ix + 479] = 1
      p[ix + 481] = 1
    end

    if x == x1 and y == y1 then
      break
    end

    local e2 = e + e
    if e2 > -dy then
      e = e - dy
      x = x + sx
    end
    if e2 < dx then
      e = e + dx
      y = y + sy
    end
  end
end

function M:new()
  local o = setmetatable({
    w = W,
    h = H,
    an = 0,
    lu = moment(),
    rs = 0.8,
    b = {},
    pp = {},
    pc = {},
  }, self)

  for i = 1, BS do
    o.b[i] = 0
  end

  for i = 1, 10 do
    o.pp[i] = 0
  end

  for i = 1, 48 do
    o.pc[i] = 0
  end

  return o
end

function M:loop()
  local p = self.b
  local pp = self.pp
  local pc = self.pc

  local ct = moment()
  local dt = (ct - self.lu) * 0.001
  self.lu = ct

  for i = 1, BS do
    p[i] = 0
  end

  local an = self.an
  local ca = co(an)
  local sa = s(an)

  for i = 0, 4 do
    local ix = i * 3
    local x = PV[ix + 1]
    local z = PV[ix + 3]

    local rx = x * ca + z * sa
    local rz = -x * sa + z * ca

    local sc = 0.8571428571428571 / (1 - rz * 0.0028571428571428571)
    local pi = i * 2
    pp[pi + 1] = f(240 + rx * sc)
    pp[pi + 2] = f(135 + PV[ix + 2] * sc)
  end

  for i = 0, 23 do
    local ix = i * 3
    local x = CV[ix + 1]
    local z = CV[ix + 3]

    local rx = x * ca + z * sa
    local rz = -x * sa + z * ca

    local sc = 0.8571428571428571 / (1 - rz * 0.0028571428571428571)
    local pi = i * 2
    pc[pi + 1] = f(240 + rx * sc)
    pc[pi + 2] = f(135 + CV[ix + 2] * sc)
  end

  for i = 1, 48, 2 do
    local i0 = (CE[i] - 1) * 2
    local i1 = (CE[i + 1] - 1) * 2
    dl(p, pc[i0 + 1], pc[i0 + 2], pc[i1 + 1], pc[i1 + 2])
  end

  for i = 1, 10, 2 do
    local i0 = (PE[i] - 1) * 2
    local i1 = (PE[i + 1] - 1) * 2
    dl(p, pp[i0 + 1], pp[i0 + 2], pp[i1 + 1], pp[i1 + 2])
  end

  local ps = {}
  local n = 0
  local i = 1

  while i <= BS do
    local v = p[i]
    local j = i + 1

    while j <= BS and p[j] == v do
      j = j + 1
    end

    n = n + 1
    ps[n] = v == 1 and r(RP, j - i) or r(TP, j - i)
    i = j
  end

  canvas.pixels = t(ps)

  self.an = self.an + self.rs * dt
  if self.an >= 6.283185307179586 then
    self.an = self.an - 6.283185307179586
  end
end

function M:teardown()
  self.b = nil
  self.pp = nil
  self.pc = nil
  canvas:clear()
end

return M:new()
