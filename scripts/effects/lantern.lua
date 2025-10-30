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
      local distance_sq = x_distances_sq[x] + y_dist_sq

      if distance_sq > OUTER_RADIUS_SQ then
        distance_sq = OUTER_RADIUS_SQ
      end

      row_buffer[col] = pixel_cache[alpha_lookup[distance_sq]]
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

function M:teardown() end

return M:new()

-- local M = {}
-- M.__index = M

-- local char = string.char
-- local concat = table.concat
-- local rep = string.rep
-- local floor = math.floor
-- local min = math.min
-- local max = math.max

-- local INNER_RADIUS = 40
-- local FADE_WIDTH = 20
-- local OUTER_RADIUS = INNER_RADIUS + FADE_WIDTH
-- local OUTER_RADIUS_SQ = OUTER_RADIUS * OUTER_RADIUS
-- local INNER_RADIUS_SQ = INNER_RADIUS * INNER_RADIUS
-- local FADE_LEVELS = 6
-- local FADE_STEP = (OUTER_RADIUS_SQ - INNER_RADIUS_SQ) / FADE_LEVELS

-- local WIDTH = 480
-- local HEIGHT = 270
-- local CENTER_X = floor(WIDTH * 0.5)
-- local CENTER_Y = floor(HEIGHT * 0.5)

-- local alpha_lookup = {}
-- for distance_sq = 0, OUTER_RADIUS_SQ do
--   if distance_sq <= INNER_RADIUS_SQ then
--     alpha_lookup[distance_sq] = 0
--   elseif distance_sq < OUTER_RADIUS_SQ then
--     local layer = floor((distance_sq - INNER_RADIUS_SQ) / FADE_STEP)
--     alpha_lookup[distance_sq] = floor((layer / (FADE_LEVELS - 1)) * 255)
--   else
--     alpha_lookup[distance_sq] = 255
--   end
-- end

-- local pixel_cache = {}
-- for alpha = 0, 255 do
--   pixel_cache[alpha] = char(0, 0, 0, alpha)
-- end

-- local opaque_pixel = pixel_cache[255]

-- local circle_rows = {}

-- for relative_y = -OUTER_RADIUS, OUTER_RADIUS do
--   local y_dist_sq = relative_y * relative_y
--   local row_pixels = {}

--   for relative_x = -OUTER_RADIUS, OUTER_RADIUS do
--     local distance_sq = relative_x * relative_x + y_dist_sq

--     if distance_sq > OUTER_RADIUS_SQ then
--       distance_sq = OUTER_RADIUS_SQ
--     end

--     row_pixels[#row_pixels + 1] = pixel_cache[alpha_lookup[distance_sq]]
--   end

--   circle_rows[relative_y] = concat(row_pixels)
-- end

-- local opaque_segments = {}
-- for i = 0, WIDTH do
--   opaque_segments[i] = rep(opaque_pixel, i)
-- end

-- local full_opaque_rows = {}
-- local opaque_row = opaque_segments[WIDTH]
-- for i = 0, HEIGHT do
--   if i == 0 then
--     full_opaque_rows[i] = ""
--   else
--     full_opaque_rows[i] = rep(opaque_row, i)
--   end
-- end

-- local parts = {}

-- local substring_cache = {}
-- local CACHE_LIMIT = 1000

-- function M:new()
--   return setmetatable({
--     w = WIDTH,
--     h = HEIGHT,
--     mouse_x = CENTER_X,
--     mouse_y = CENTER_Y,
--     last_rendered_x = nil,
--     last_rendered_y = nil,
--   }, self)
-- end

-- function M:motion(x, y)
--   self.mouse_x = floor(x)
--   self.mouse_y = floor(y)
-- end

-- local function get_circle_segment(relative_y, start_offset, length)
--   local full_row = circle_rows[relative_y]

--   local byte_start = start_offset * 4 + 1
--   local byte_end = byte_start + length * 4 - 1

--   return full_row:sub(byte_start, byte_end)
-- end

-- function M:loop()
--   local mouse_x = self.mouse_x
--   local mouse_y = self.mouse_y

--   if mouse_x == self.last_rendered_x and mouse_y == self.last_rendered_y then
--     return
--   end

--   self.last_rendered_x = mouse_x
--   self.last_rendered_y = mouse_y

--   local min_y = max(0, mouse_y - OUTER_RADIUS)
--   local max_y = min(HEIGHT - 1, mouse_y + OUTER_RADIUS)
--   local min_x = max(0, mouse_x - OUTER_RADIUS)
--   local max_x = min(WIDTH - 1, mouse_x + OUTER_RADIUS)

--   local dynamic_width = max_x - min_x + 1
--   local dynamic_height = max_y - min_y + 1

--   local prefix = opaque_segments[min_x]
--   local suffix = opaque_segments[WIDTH - max_x - 1]

--   local part_count = 0

--   if min_y > 0 then
--     part_count = part_count + 1
--     parts[part_count] = full_opaque_rows[min_y]
--   end

--   local circle_x_start = min_x - (mouse_x - OUTER_RADIUS)

--   for row = 0, dynamic_height - 1 do
--     local y = min_y + row
--     local relative_y = y - mouse_y

--     local circle_segment = get_circle_segment(relative_y, circle_x_start, dynamic_width)

--     part_count = part_count + 1
--     parts[part_count] = prefix
--     part_count = part_count + 1
--     parts[part_count] = circle_segment
--     part_count = part_count + 1
--     parts[part_count] = suffix
--   end

--   local remaining_rows = HEIGHT - max_y - 1
--   if remaining_rows > 0 then
--     part_count = part_count + 1
--     parts[part_count] = full_opaque_rows[remaining_rows]
--   end

--   for i = part_count + 1, #parts do
--     parts[i] = nil
--   end

--   canvas.pixels = concat(parts)
-- end

-- function M:teardown()
--   for i = 1, #parts do
--     parts[i] = nil
--   end

--   if substring_cache and next(substring_cache) then
--     local count = 0
--     for _ in pairs(substring_cache) do
--       count = count + 1
--     end
--     if count > CACHE_LIMIT then
--       substring_cache = {}
--     end
--   end
-- end

-- return M:new()
