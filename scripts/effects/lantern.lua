local M = {}
M.__index = M

local char = string.char
local join = table.concat
local rep = string.rep
local floor = math.floor

local R = 40
local F = 20
local TR = R + F
local MAXD2 = TR * TR
local MIND2 = R * R
local LV = 6
local STEP = (MAXD2 - MIND2) / LV

function M:new()
  local ww = 480
  local hh = 270
  local px = {}
  for i = 0, 255 do
    px[i] = char(0, 0, 0, i)
  end
  local amap = {}
  for d2 = 0, MAXD2 do
    if d2 <= MIND2 then
      amap[d2] = 0
    end
    if d2 > MIND2 and d2 < MAXD2 then
      local layer = floor((d2 - MIND2) / STEP)
      amap[d2] = floor((layer / (LV - 1)) * 255)
    end
    if d2 >= MAXD2 then
      amap[d2] = 255
    end
  end
  local dx2 = {}
  for i = 1, ww do
    dx2[i] = 0
  end
  local dy2 = {}
  for i = 1, hh do
    dy2[i] = 0
  end
  return setmetatable({
    w = ww,
    h = hh,
    px = px,
    amap = amap,
    dx2 = dx2,
    dy2 = dy2,
    rowbuf = {},
    opaque_px = px[255],
    opaque_row = rep(px[255], ww),
    cx = floor(ww * 0.5),
    cy = floor(hh * 0.5),
  }, self)
end

function M:motion(x, y)
  self.cx = floor(x)
  self.cy = floor(y)
end

function M:loop()
  local w, h = self.w, self.h
  local cx, cy = self.cx, self.cy
  local px, amap = self.px, self.amap
  local dx2, dy2 = self.dx2, self.dy2
  local rowbuf = self.rowbuf
  local opaque_px, opaque_row = self.opaque_px, self.opaque_row

  for x = 0, w - 1 do
    local d = x - cx
    dx2[x + 1] = d * d
  end
  for y = 0, h - 1 do
    local d = y - cy
    dy2[y + 1] = d * d
  end

  local y0 = cy - TR
  if y0 < 0 then
    y0 = 0
  end
  if y0 > h - 1 then
    y0 = h - 1
  end
  local y1 = cy + TR
  if y1 > h - 1 then
    y1 = h - 1
  end
  if y1 < 0 then
    y1 = 0
  end
  local x0 = cx - TR
  if x0 < 0 then
    x0 = 0
  end
  if x0 > w - 1 then
    x0 = w - 1
  end
  local x1 = cx + TR
  if x1 > w - 1 then
    x1 = w - 1
  end
  if x1 < 0 then
    x1 = 0
  end

  local dynW = x1 - x0 + 1
  local dynH = y1 - y0 + 1
  local pre = rep(opaque_px, x0)
  local suf = rep(opaque_px, w - (x1 + 1))

  local parts = {}
  local top = y0
  if top > 0 then
    parts[#parts + 1] = rep(opaque_row, top)
  end

  if dynH > 0 then
    for r = 1, dynH do
      local yi = y0 + r - 1
      local ddy = dy2[yi + 1]
      for c = 1, dynW do
        local xi = x0 + c - 1
        local d2 = dx2[xi + 1] + ddy
        if d2 > MAXD2 then
          d2 = MAXD2
        end
        local a = amap[d2]
        rowbuf[c] = px[a]
      end
      parts[#parts + 1] = pre
      parts[#parts + 1] = join(rowbuf, "", 1, dynW)
      parts[#parts + 1] = suf
    end
  end

  local bot = h - (y0 + dynH)
  if bot > 0 then
    parts[#parts + 1] = rep(opaque_row, bot)
  end

  canvas.pixels = join(parts, "")
end

function M:teardown()
  self.opaque_row = nil
  self.opaque_px = nil
  self.rowbuf = nil
end

return M:new()
