local M = {}
M.__index = M

local char = string.char
local concat = table.concat
local rep = string.rep
local floor = math.floor

local INNER_RADIUS = 40
local FADE_WIDTH = 20
local OUTER_RADIUS = INNER_RADIUS + FADE_WIDTH
local OUTER_RADIUS_SQ = OUTER_RADIUS * OUTER_RADIUS
local INNER_RADIUS_SQ = INNER_RADIUS * INNER_RADIUS
local FADE_LEVELS = 6
local FADE_STEP = (OUTER_RADIUS_SQ - INNER_RADIUS_SQ) / FADE_LEVELS

local WIDTH = 480
local HEIGHT = 270
local CENTER_X = floor(WIDTH * 0.5)
local CENTER_Y = floor(HEIGHT * 0.5)

local alpha_lookup = {}
for distance_sq = 0, OUTER_RADIUS_SQ do
  if distance_sq <= INNER_RADIUS_SQ then
    alpha_lookup[distance_sq] = 0
  elseif distance_sq < OUTER_RADIUS_SQ then
    local layer = floor((distance_sq - INNER_RADIUS_SQ) / FADE_STEP)
    alpha_lookup[distance_sq] = floor((layer / (FADE_LEVELS - 1)) * 255)
  else
    alpha_lookup[distance_sq] = 255
  end
end

local pixel_cache = {}
for alpha = 0, 255 do
  pixel_cache[alpha] = char(0, 0, 0, alpha)
end

local opaque_pixel = pixel_cache[255]
local opaque_row = rep(opaque_pixel, WIDTH)

local x_distances_sq = {}
local y_distances_sq = {}
local row_buffer = {}

function M:new()
  return setmetatable({
    w = WIDTH,
    h = HEIGHT,
    mouse_x = CENTER_X,
    mouse_y = CENTER_Y,
    last_rendered_x = nil,
    last_rendered_y = nil,
  }, self)
end

function M:motion(x, y)
  self.mouse_x = floor(x)
  self.mouse_y = floor(y)
end

function M:loop()
  local mouse_x = self.mouse_x
  local mouse_y = self.mouse_y

  if mouse_x == self.last_rendered_x and mouse_y == self.last_rendered_y then
    return
  end

  self.last_rendered_x = mouse_x
  self.last_rendered_y = mouse_y

  for x = 0, WIDTH - 1 do
    local delta = x - mouse_x
    x_distances_sq[x] = delta * delta
  end

  for y = 0, HEIGHT - 1 do
    local delta = y - mouse_y
    y_distances_sq[y] = delta * delta
  end

  local min_y = mouse_y - OUTER_RADIUS
  if min_y < 0 then
    min_y = 0
  end

  local max_y = mouse_y + OUTER_RADIUS
  if max_y > HEIGHT - 1 then
    max_y = HEIGHT - 1
  end

  local min_x = mouse_x - OUTER_RADIUS
  if min_x < 0 then
    min_x = 0
  end

  local max_x = mouse_x + OUTER_RADIUS
  if max_x > WIDTH - 1 then
    max_x = WIDTH - 1
  end

  local dynamic_width = max_x - min_x + 1
  local dynamic_height = max_y - min_y + 1

  local prefix = rep(opaque_pixel, min_x)
  local suffix = rep(opaque_pixel, WIDTH - max_x - 1)

  local parts = {}
  local part_count = 0

  if min_y > 0 then
    part_count = part_count + 1
    parts[part_count] = rep(opaque_row, min_y)
  end

  for row = 0, dynamic_height - 1 do
    local y = min_y + row
    local y_dist_sq = y_distances_sq[y]

    for col = 1, dynamic_width do
      local x = min_x + col - 1
      local dist_sq = x_distances_sq[x] + y_dist_sq
      local clamped = dist_sq > OUTER_RADIUS_SQ and OUTER_RADIUS_SQ or dist_sq
      row_buffer[col] = pixel_cache[alpha_lookup[clamped]]
    end

    part_count = part_count + 1
    parts[part_count] = prefix
    part_count = part_count + 1
    parts[part_count] = concat(row_buffer, "", 1, dynamic_width)
    part_count = part_count + 1
    parts[part_count] = suffix
  end

  local remaining_rows = HEIGHT - max_y - 1
  if remaining_rows > 0 then
    part_count = part_count + 1
    parts[part_count] = rep(opaque_row, remaining_rows)
  end

  canvas.pixels = concat(parts)
end

function M:teardown()
  for i = 0, WIDTH - 1 do
    x_distances_sq[i] = nil
  end

  for i = 0, HEIGHT - 1 do
    y_distances_sq[i] = nil
  end

  for i = 1, WIDTH do
    row_buffer[i] = nil
  end

  canvas:clear()
end

return M:new()
