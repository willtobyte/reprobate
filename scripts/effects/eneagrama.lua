local M = {}
M.__index = M

local floor = math.floor
local cos = math.cos
local sin = math.sin
local pi = math.pi
local char = string.char
local concat = table.concat
local rep = string.rep
local abs = math.abs
local sqrt = math.sqrt

local WIDTH = 480
local HEIGHT = 270

local CX = 240
local CY = 135

local LINE_THICKNESS = 2
local CIRCLE_THICKNESS = 2
local ROTATION_SPEED = 1.8

local TRANSPARENT = char(0, 0, 0, 0)
local RED = char(255, 0, 0, 255)

local transparent_span = { [0] = "" }
local red_span = { [0] = "" }
for i = 1, WIDTH do
  transparent_span[i] = rep(TRANSPARENT, i)
  red_span[i] = rep(RED, i)
end

local TRANSPARENT_ROW = transparent_span[WIDTH]

local MAX_SPANS_PER_ROW = 32

local row_span_x0 = {}
local row_span_x1 = {}
local row_span_n = {}
for y = 0, HEIGHT - 1 do
  row_span_x0[y] = {}
  row_span_x1[y] = {}
  row_span_n[y] = 0
  for i = 1, MAX_SPANS_PER_ROW do
    row_span_x0[y][i] = 0
    row_span_x1[y][i] = 0
  end
end

local row_strings = {}
for y = 1, HEIGHT do
  row_strings[y] = TRANSPARENT_ROW
end

local parts = {}
for i = 1, 64 do
  parts[i] = ""
end

local merge_x0 = {}
local merge_x1 = {}
for i = 1, MAX_SPANS_PER_ROW do
  merge_x0[i] = 0
  merge_x1[i] = 0
end

local function add_span(y, x0, x1)
  if y < 0 or y >= HEIGHT then
    return
  end
  if x0 > x1 then
    return
  end
  if x0 < 0 then
    x0 = 0
  end
  if x1 >= WIDTH then
    x1 = WIDTH - 1
  end
  local n = row_span_n[y] + 1
  if n > MAX_SPANS_PER_ROW then
    return
  end
  row_span_x0[y][n] = x0
  row_span_x1[y][n] = x1
  row_span_n[y] = n
end

local function rasterize_line(px0, py0, px1, py1, half_t)
  local dx = px1 - px0
  local dy = py1 - py0
  local len_sq = dx * dx + dy * dy
  if len_sq < 0.0001 then
    return
  end

  local len = sqrt(len_sq)
  local inv_len = 1.0 / len

  local tx = dx * inv_len
  local ty = dy * inv_len
  local nx = -ty
  local ny = tx

  local y_lo = py0 < py1 and py0 or py1
  local y_hi = py0 > py1 and py0 or py1
  local iy_min = floor(y_lo - half_t)
  local iy_max = floor(y_hi + half_t)
  if iy_min < 0 then
    iy_min = 0
  end
  if iy_max >= HEIGHT then
    iy_max = HEIGHT - 1
  end

  for y = iy_min, iy_max do
    local yf = y + 0.5
    local rel_y = yf - py0

    local perp_base = nx * px0 - ny * rel_y

    local x_start, x_end

    if abs(nx) > 0.0001 then
      local inv_nx = 1.0 / nx
      local a = (perp_base - half_t) * inv_nx
      local b = (perp_base + half_t) * inv_nx
      if a > b then
        a, b = b, a
      end
      x_start = a
      x_end = b
    else
      local dist = abs(ny * rel_y)
      if dist <= half_t then
        x_start = (px0 < px1 and px0 or px1) - half_t
        x_end = (px0 > px1 and px0 or px1) + half_t
      else
        x_start = 1
        x_end = 0
      end
    end

    local along_offset = ty * rel_y

    if abs(tx) > 0.0001 then
      local inv_tx = 1.0 / tx
      local seg_a = px0 + (0 - along_offset) * inv_tx
      local seg_b = px0 + (len - along_offset) * inv_tx
      if seg_a > seg_b then
        seg_a, seg_b = seg_b, seg_a
      end
      if seg_a > x_start then
        x_start = seg_a
      end
      if seg_b < x_end then
        x_end = seg_b
      end
    else
      if along_offset < 0 or along_offset > len then
        x_start = 1
        x_end = 0
      end
    end

    local ix0 = floor(x_start + 0.5)
    local ix1 = floor(x_end + 0.5)
    if ix0 <= ix1 then
      add_span(y, ix0, ix1)
    end
  end
end

local function rasterize_circle(rx, ry)
  local orx = rx + CIRCLE_THICKNESS
  local ory = ry + CIRCLE_THICKNESS
  local irx = rx - CIRCLE_THICKNESS
  local iry = ry - CIRCLE_THICKNESS
  if irx < 0 then
    irx = 0
  end
  if iry < 0 then
    iry = 0
  end

  local iy_min = floor(CY - ory)
  local iy_max = floor(CY + ory)
  if iy_min < 0 then
    iy_min = 0
  end
  if iy_max >= HEIGHT then
    iy_max = HEIGHT - 1
  end

  local ory_sq = ory * ory
  local iry_sq = iry * iry
  if ory_sq < 1 then
    ory_sq = 1
  end
  if iry_sq < 1 then
    iry_sq = 1
  end

  for iy = iy_min, iy_max do
    local dy = iy - CY
    local dy_sq = dy * dy

    local ot = 1.0 - dy_sq / ory_sq
    if ot > 0 then
      local oh = orx * sqrt(ot)
      local ox0 = floor(CX - oh + 0.5)
      local ox1 = floor(CX + oh + 0.5)
      if ox0 < 0 then
        ox0 = 0
      end
      if ox1 >= WIDTH then
        ox1 = WIDTH - 1
      end

      local it = 1.0 - dy_sq / iry_sq
      if it > 0 and irx > 0 then
        local ih = irx * sqrt(it)
        local ix0 = floor(CX - ih + 0.5)
        local ix1 = floor(CX + ih + 0.5)

        local le = ix0 - 1
        if le >= ox0 then
          if le >= WIDTH then
            le = WIDTH - 1
          end
          add_span(iy, ox0, le)
        end

        local rs = ix1 + 1
        if rs <= ox1 then
          if rs < 0 then
            rs = 0
          end
          add_span(iy, rs, ox1)
        end
      else
        add_span(iy, ox0, ox1)
      end
    end
  end
end

local function sort_row_spans(sx0, sx1, n)
  for i = 2, n do
    local kx0 = sx0[i]
    local kx1 = sx1[i]
    local j = i - 1
    while j >= 1 and sx0[j] > kx0 do
      sx0[j + 1] = sx0[j]
      sx1[j + 1] = sx1[j]
      j = j - 1
    end
    sx0[j + 1] = kx0
    sx1[j + 1] = kx1
  end
end

local function build_row(y)
  local n = row_span_n[y]
  if n == 0 then
    return TRANSPARENT_ROW
  end

  local sx0 = row_span_x0[y]
  local sx1 = row_span_x1[y]

  if n > 1 then
    sort_row_spans(sx0, sx1, n)
  end

  local mn = 1
  merge_x0[1] = sx0[1]
  merge_x1[1] = sx1[1]
  for i = 2, n do
    if sx0[i] <= merge_x1[mn] + 1 then
      if sx1[i] > merge_x1[mn] then
        merge_x1[mn] = sx1[i]
      end
    else
      mn = mn + 1
      merge_x0[mn] = sx0[i]
      merge_x1[mn] = sx1[i]
    end
  end

  local pi_idx = 0
  local cursor = 0

  for i = 1, mn do
    local x0 = merge_x0[i]
    local x1 = merge_x1[i]

    local gap = x0 - cursor
    if gap > 0 then
      pi_idx = pi_idx + 1
      parts[pi_idx] = transparent_span[gap]
    end

    local rlen = x1 - x0 + 1
    if rlen > 0 then
      pi_idx = pi_idx + 1
      parts[pi_idx] = red_span[rlen]
    end

    cursor = x1 + 1
  end

  local remaining = WIDTH - cursor
  if remaining > 0 then
    pi_idx = pi_idx + 1
    parts[pi_idx] = transparent_span[remaining]
  end

  return concat(parts, nil, 1, pi_idx)
end

local prev_y_min = 0
local prev_y_max = -1

local function build_star_geometry(n, radius)
  local vx = {}
  local vy = {}

  for k = 0, n - 1 do
    local a = pi * 0.5 + k * 2.0 * pi / n
    vx[k] = radius * cos(a)
    vy[k] = radius * sin(a)
  end

  local skip = floor(n / 2)

  local visited = {}
  local ev0 = {}
  local ev1 = {}
  local ne = 0

  for start = 0, n - 1 do
    if not visited[start] then
      local cur = start
      repeat
        local nxt = (cur + skip) % n
        ne = ne + 1
        ev0[ne] = cur
        ev1[ne] = nxt
        visited[cur] = true
        cur = nxt
      until cur == start
    end
  end

  return vx, vy, ev0, ev1, ne, n
end

function M:new(n, radius)
  n = n or 5
  radius = radius or 100

  local vx, vy, ev0, ev1, ne, nv = build_star_geometry(n, radius)

  local px = {}
  local py = {}
  for k = 0, nv - 1 do
    px[k] = 0
    py[k] = 0
  end

  return setmetatable({
    angle = 0.0,
    radius = radius,
    base_vx = vx,
    base_vy = vy,
    edge_v0 = ev0,
    edge_v1 = ev1,
    num_edges = ne,
    num_verts = nv,
    proj_x = px,
    proj_y = py,
  }, self)
end

function M:loop(delta)
  self.angle = self.angle + delta * ROTATION_SPEED

  local angle = self.angle
  local cos_a = cos(angle)
  local abs_cos = abs(cos_a)
  local radius = self.radius

  local margin = CIRCLE_THICKNESS + LINE_THICKNESS + 2
  local region_y_min = floor(CY - radius - margin)
  local region_y_max = floor(CY + radius + margin)
  if region_y_min < 0 then
    region_y_min = 0
  end
  if region_y_max >= HEIGHT then
    region_y_max = HEIGHT - 1
  end

  for y = prev_y_min, prev_y_max do
    row_strings[y + 1] = TRANSPARENT_ROW
  end

  local reset_min = region_y_min
  local reset_max = region_y_max
  if prev_y_min < reset_min then
    reset_min = prev_y_min
  end
  if prev_y_max > reset_max then
    reset_max = prev_y_max
  end

  for y = reset_min, reset_max do
    row_span_n[y] = 0
  end

  local bvx = self.base_vx
  local bvy = self.base_vy
  local px = self.proj_x
  local py = self.proj_y
  local nv = self.num_verts

  for k = 0, nv - 1 do
    px[k] = CX + bvx[k] * cos_a
    py[k] = CY + bvy[k]
  end

  local ev0 = self.edge_v0
  local ev1 = self.edge_v1
  local ne = self.num_edges

  for i = 1, ne do
    local a = ev0[i]
    local b = ev1[i]
    rasterize_line(px[a], py[a], px[b], py[b], LINE_THICKNESS)
  end

  local proj_rx = radius * abs_cos
  rasterize_circle(proj_rx, radius)

  for y = region_y_min, region_y_max do
    row_strings[y + 1] = build_row(y)
  end

  prev_y_min = region_y_min
  prev_y_max = region_y_max

  canvas.pixels = concat(row_strings, nil, 1, HEIGHT)
end

function M:teardown()
  canvas:clear()
end

return M
