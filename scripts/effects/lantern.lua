-- local M = {}
-- M.__index = M

-- local char = string.char
-- local join = table.concat
-- local rep = string.rep
-- local floor = math.floor

-- local R = 40
-- local F = 20
-- local TR = R + F
-- local MAXD2 = TR * TR
-- local MIND2 = R * R
-- local LV = 6
-- local STEP = (MAXD2 - MIND2) / LV

-- function M:new(w, h)
--   local ww = w or 480
--   local hh = h or 270
--   local px = {}
--   for i = 0, 255 do
--     px[i] = char(0, 0, 0, i)
--   end
--   local amap = {}
--   for d2 = 0, MAXD2 do
--     if d2 <= MIND2 then
--       amap[d2] = 0
--     end
--     if d2 > MIND2 and d2 < MAXD2 then
--       local layer = floor((d2 - MIND2) / STEP)
--       amap[d2] = floor((layer / (LV - 1)) * 255)
--     end
--     if d2 >= MAXD2 then
--       amap[d2] = 255
--     end
--   end
--   local dx2 = {}
--   for i = 1, ww do
--     dx2[i] = 0
--   end
--   local dy2 = {}
--   for i = 1, hh do
--     dy2[i] = 0
--   end
--   return setmetatable({
--     w = ww,
--     h = hh,
--     px = px,
--     amap = amap,
--     dx2 = dx2,
--     dy2 = dy2,
--     rowbuf = {},
--     opaque_px = px[255],
--     opaque_row = rep(px[255], ww),
--     cx = floor(ww * 0.5),
--     cy = floor(hh * 0.5),
--   }, self)
-- end

-- function M:motion(x, y)
--   self.cx = floor(x)
--   self.cy = floor(y)
-- end

-- function M:loop()
--   local w, h = self.w, self.h
--   local cx, cy = self.cx, self.cy
--   local px, amap = self.px, self.amap
--   local dx2, dy2 = self.dx2, self.dy2
--   local rowbuf = self.rowbuf
--   local opaque_px, opaque_row = self.opaque_px, self.opaque_row

--   for x = 0, w - 1 do
--     local d = x - cx
--     dx2[x + 1] = d * d
--   end
--   for y = 0, h - 1 do
--     local d = y - cy
--     dy2[y + 1] = d * d
--   end

--   local y0 = cy - TR
--   if y0 < 0 then
--     y0 = 0
--   end
--   if y0 > h - 1 then
--     y0 = h - 1
--   end
--   local y1 = cy + TR
--   if y1 > h - 1 then
--     y1 = h - 1
--   end
--   if y1 < 0 then
--     y1 = 0
--   end
--   local x0 = cx - TR
--   if x0 < 0 then
--     x0 = 0
--   end
--   if x0 > w - 1 then
--     x0 = w - 1
--   end
--   local x1 = cx + TR
--   if x1 > w - 1 then
--     x1 = w - 1
--   end
--   if x1 < 0 then
--     x1 = 0
--   end

--   local dynW = x1 - x0 + 1
--   local dynH = y1 - y0 + 1
--   local pre = rep(opaque_px, x0)
--   local suf = rep(opaque_px, w - (x1 + 1))

--   local parts = {}
--   local top = y0
--   if top > 0 then
--     parts[#parts + 1] = rep(opaque_row, top)
--   end

--   if dynH > 0 then
--     for r = 1, dynH do
--       local yi = y0 + r - 1
--       local ddy = dy2[yi + 1]
--       for c = 1, dynW do
--         local xi = x0 + c - 1
--         local d2 = dx2[xi + 1] + ddy
--         if d2 > MAXD2 then
--           d2 = MAXD2
--         end
--         local a = amap[d2]
--         rowbuf[c] = px[a]
--       end
--       parts[#parts + 1] = pre
--       parts[#parts + 1] = join(rowbuf, "", 1, dynW)
--       parts[#parts + 1] = suf
--     end
--   end

--   local bot = h - (y0 + dynH)
--   if bot > 0 then
--     parts[#parts + 1] = rep(opaque_row, bot)
--   end

--   canvas.pixels = join(parts, "")
-- end

-- function M:teardown()
--   self.opaque_row = nil
--   self.opaque_px = nil
--   self.rowbuf = nil
-- end

-- return M:new()

local L = {}
L.__index = L

local ch = string.char
local join = table.concat
local rep = string.rep
local floor = math.floor
local has_jit = type(jit) == "table" and jit.status()
local ok_ffi, ffi = pcall(require, "ffi")
if not ok_ffi then
  has_jit = false
end

local R = 40
local F = 20
local TR = R + F
local MAXD2 = TR * TR
local MIND2 = R * R
local LV = 6
local STEP = (MAXD2 - MIND2) / LV

function L:new(width, height)
  local w = width or 480
  local h = height or 270

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
  for i = 1, w do
    dx2[i] = 0
  end
  local dy2 = {}
  for i = 1, h do
    dy2[i] = 0
  end

  if has_jit then
    ffi.cdef("typedef unsigned char u8;")
    local buf = ffi.new("u8[?]", w * h * 4)
    return setmetatable({
      w = w,
      h = h,
      px = px,
      amap = amap,
      dx2 = dx2,
      dy2 = dy2,
      row = {},
      cx = floor(w * 0.5),
      cy = floor(h * 0.5),
      buf = buf,
    }, self)
  end

  local opaque_px = px[255]
  local opaque_row = rep(opaque_px, w)

  return setmetatable({
    w = w,
    h = h,
    px = px,
    amap = amap,
    dx2 = dx2,
    dy2 = dy2,
    row = {},
    cx = floor(w * 0.5),
    cy = floor(h * 0.5),
    opaque_px = opaque_px,
    opaque_row = opaque_row,
  }, self)
end

function L:motion(x, y)
  self.cx = floor(x)
  self.cy = floor(y)
end

function L:loop()
  local w, h = self.w, self.h
  local cx, cy = self.cx, self.cy
  local amap = self.amap
  local dx2, dy2 = self.dx2, self.dy2

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

  if has_jit then
    local buf = self.buf
    local stride = w * 4
    local function setpx(i, a)
      local j = i * 4
      buf[j] = 0
      buf[j + 1] = 0
      buf[j + 2] = 0
      buf[j + 3] = a
    end

    local top = y0
    local bot = h - (y0 + dynH)

    if top > 0 then
      local count = top * w
      local base = 0
      for i = 0, count - 1 do
        setpx(base + i, 255)
      end
    end

    if dynH > 0 then
      for r = 0, dynH - 1 do
        local y = y0 + r
        local row_base = (top + r) * w
        local pre = x0
        local suf = w - (x1 + 1)
        if pre > 0 then
          for i = 0, pre - 1 do
            setpx(row_base + i, 255)
          end
        end
        local ddy = dy2[y + 1]
        if dynW > 0 then
          for c = 0, dynW - 1 do
            local x = x0 + c
            local d2 = dx2[x + 1] + ddy
            if d2 > MAXD2 then
              d2 = MAXD2
            end
            setpx(row_base + pre + c, amap[d2])
          end
        end
        if suf > 0 then
          local start = row_base + pre + dynW
          for i = 0, suf - 1 do
            setpx(start + i, 255)
          end
        end
      end
    end

    if bot > 0 then
      local start = (top + dynH) * w
      local count = bot * w
      for i = 0, count - 1 do
        setpx(start + i, 255)
      end
    end

    canvas.pixels = ffi.string(buf, w * h * 4)
    return
  end

  local px = self.px
  local row = self.row
  local opaque_px = self.opaque_px
  local opaque_row = self.opaque_row
  local pre = rep(opaque_px, x0)
  local suf = rep(opaque_px, w - (x1 + 1))

  local parts = {}
  local top = y0
  if top > 0 then
    parts[#parts + 1] = rep(opaque_row, top)
  end

  if dynH > 0 then
    for r = 1, dynH do
      local y = y0 + r - 1
      local ddy = dy2[y + 1]
      for c = 1, dynW do
        local x = x0 + c - 1
        local d2 = dx2[x + 1] + ddy
        if d2 > MAXD2 then
          d2 = MAXD2
        end
        row[c] = px[amap[d2]]
      end
      parts[#parts + 1] = pre
      parts[#parts + 1] = join(row, "", 1, dynW)
      parts[#parts + 1] = suf
    end
  end

  local bot = h - (y0 + dynH)
  if bot > 0 then
    parts[#parts + 1] = rep(opaque_row, bot)
  end

  canvas.pixels = join(parts, "")
end

function L:teardown()
  self.opaque_row = nil
  self.opaque_px = nil
  self.row = nil
  self.buf = nil
end

return L:new()
