local M = {}
M.__index = M

local floor = math.floor
local min = math.min
local max = math.max

local INNER_RADIUS = 40
local FADE_WIDTH = 20
local OUTER_RADIUS = INNER_RADIUS + FADE_WIDTH
local OUTER_RADIUS_SQ = OUTER_RADIUS * OUTER_RADIUS
local INNER_RADIUS_SQ = INNER_RADIUS * INNER_RADIUS
local FADE_RANGE = OUTER_RADIUS_SQ - INNER_RADIUS_SQ

local WIDTH = 480
local HEIGHT = 270
local CENTER_X = floor(WIDTH * 0.5)
local CENTER_Y = floor(HEIGHT * 0.5)
local TOTAL_PIXELS = WIDTH * HEIGHT
local BUFFER_SIZE = TOTAL_PIXELS * 4

local ffi = rawget(_G, "jit") and require("ffi")

if ffi then
  local buffer = ffi.new("uint8_t[?]", BUFFER_SIZE)
  local ffi_copy = ffi.copy
  local ffi_fill = ffi.fill
  local ffi_string = ffi.string

  for i = 0, TOTAL_PIXELS - 1 do
    local offset = i * 4
    buffer[offset + 3] = 255
  end

  local opaque_buffer = ffi.new("uint8_t[?]", BUFFER_SIZE)
  ffi_copy(opaque_buffer, buffer, BUFFER_SIZE)

  function M:new()
    return setmetatable({
      mouse_x = CENTER_X,
      mouse_y = CENTER_Y,
      last_x = nil,
      last_y = nil,
    }, self)
  end

  function M:motion(x, y)
    self.mouse_x = floor(x)
    self.mouse_y = floor(y)
  end

  function M:loop()
    local mx = self.mouse_x
    local my = self.mouse_y

    if mx == self.last_x and my == self.last_y then
      return
    end

    self.last_x = mx
    self.last_y = my

    ffi_copy(buffer, opaque_buffer, BUFFER_SIZE)

    local y_start = max(0, my - OUTER_RADIUS)
    local y_end = min(HEIGHT - 1, my + OUTER_RADIUS)

    for y = y_start, y_end do
      local dy = y - my
      local dy_sq = dy * dy
      local max_dx_sq = OUTER_RADIUS_SQ - dy_sq
      if max_dx_sq > 0 then
        local max_dx = floor(max_dx_sq ^ 0.5)
        local x_start = max(0, mx - max_dx)
        local x_end = min(WIDTH - 1, mx + max_dx)
        local row_offset = y * WIDTH * 4

        for x = x_start, x_end do
          local dx = x - mx
          local dist_sq = dx * dx + dy_sq
          local alpha
          if dist_sq <= INNER_RADIUS_SQ then
            alpha = 0
          else
            alpha = floor(((dist_sq - INNER_RADIUS_SQ) / FADE_RANGE) * 255)
            if alpha > 255 then
              alpha = 255
            end
          end
          buffer[row_offset + x * 4 + 3] = alpha
        end
      end
    end

    canvas.pixels = ffi_string(buffer, BUFFER_SIZE)
  end

  function M:teardown()
    canvas:clear()
  end
else
  local char = string.char
  local concat = table.concat
  local rep = string.rep

  local pixel_cache = {}
  for alpha = 0, 255 do
    pixel_cache[alpha] = char(0, 0, 0, alpha)
  end

  local opaque = pixel_cache[255]
  local opaque_row = rep(opaque, WIDTH)
  local full_opaque = rep(opaque_row, HEIGHT)

  local prefix_cache = { [0] = "" }
  local suffix_cache = { [0] = "" }
  for i = 1, WIDTH do
    prefix_cache[i] = rep(opaque, i)
    suffix_cache[i] = prefix_cache[i]
  end

  local row_top_cache = { [0] = "" }
  local row_bot_cache = { [0] = "" }
  for i = 1, HEIGHT do
    row_top_cache[i] = rep(opaque_row, i)
    row_bot_cache[i] = row_top_cache[i]
  end

  local parts = {}
  local row_pixels = {}

  function M:new()
    return setmetatable({
      mouse_x = CENTER_X,
      mouse_y = CENTER_Y,
      last_x = nil,
      last_y = nil,
    }, self)
  end

  function M:motion(x, y)
    self.mouse_x = floor(x)
    self.mouse_y = floor(y)
  end

  function M:loop()
    local mx = self.mouse_x
    local my = self.mouse_y

    if mx == self.last_x and my == self.last_y then
      return
    end

    self.last_x = mx
    self.last_y = my

    local y_start = my - OUTER_RADIUS
    if y_start < 0 then
      y_start = 0
    end

    local y_end = my + OUTER_RADIUS
    if y_end > HEIGHT - 1 then
      y_end = HEIGHT - 1
    end

    local x_start_base = mx - OUTER_RADIUS
    if x_start_base < 0 then
      x_start_base = 0
    end

    local x_end_base = mx + OUTER_RADIUS
    if x_end_base > WIDTH - 1 then
      x_end_base = WIDTH - 1
    end

    local pi = 0

    if y_start > 0 then
      pi = pi + 1
      parts[pi] = row_top_cache[y_start]
    end

    local prefix_len = x_start_base
    local suffix_len = WIDTH - x_end_base - 1
    local prefix_str = prefix_cache[prefix_len]
    local suffix_str = suffix_cache[suffix_len]
    local row_width = x_end_base - x_start_base + 1

    for y = y_start, y_end do
      local dy = y - my
      local dy_sq = dy * dy
      local ri = 0

      for x = x_start_base, x_end_base do
        local dx = x - mx
        local dist_sq = dx * dx + dy_sq
        local alpha
        if dist_sq <= INNER_RADIUS_SQ then
          alpha = 0
        elseif dist_sq >= OUTER_RADIUS_SQ then
          alpha = 255
        else
          alpha = floor(((dist_sq - INNER_RADIUS_SQ) / FADE_RANGE) * 255)
        end
        ri = ri + 1
        row_pixels[ri] = pixel_cache[alpha]
      end

      pi = pi + 1
      parts[pi] = prefix_str
      pi = pi + 1
      parts[pi] = concat(row_pixels, "", 1, row_width)
      pi = pi + 1
      parts[pi] = suffix_str
    end

    local remaining = HEIGHT - y_end - 1
    if remaining > 0 then
      pi = pi + 1
      parts[pi] = row_bot_cache[remaining]
    end

    canvas.pixels = concat(parts, "", 1, pi)
  end

  function M:teardown()
    canvas:clear()
  end
end

return M:new()
