local NoiseEffect = {}
NoiseEffect.__index = NoiseEffect

local char, concat, floor = string.char, table.concat, math.floor

local seed = 666
local function random()
  seed = (1103515245 * seed + 12345) % 2147483648
  return seed
end

function NoiseEffect:new(width, height, duration)
  local w, h = width or 480, height or 270
  return setmetatable({
    width = w,
    height = h,
    duration = duration or 2000,
    start_time = nil,
    callback = nil,
    pixel_count = w * h,
    buffer = {},
    cache = {},
    done = false,
  }, self)
end

function NoiseEffect:init()
  self.start_time = moment()
end

function NoiseEffect:on_finish(callback)
  self.callback = callback
end

local function fill_block(buffer, width, height, x, y, bw, bh, px)
  for dy = 0, bh - 1 do
    local row = y + dy
    if row >= height then
      break
    end
    for dx = 0, bw - 1 do
      local col = x + dx
      if col >= width then
        break
      end
      local idx = row * width + col + 1
      buffer[idx] = px
    end
  end
end

function NoiseEffect:loop()
  if self.done then
    return
  end

  local now = moment()
  local elapsed = now - self.start_time
  local duration = self.duration
  local w, h = self.width, self.height
  local total = self.pixel_count
  local buffer, cache = self.buffer, self.cache

  if elapsed >= duration then
    for i = 1, total do
      buffer[i] = char(0, 0, 0, 0)
    end
    canvas.pixels = concat(buffer, "", 1, total)
    if self.callback then
      self.callback()
      self.callback = nil
    end

    self.done = true
    return
  end

  local fade = 1 - (elapsed / duration)
  local alpha = floor(255 * fade)

  for i = 1, total do
    local r = random() % 256
    local g = random() % 256
    local b = random() % 256
    local key = r * 16777216 + g * 65536 + b * 256 + alpha
    local px = cache[key]
    if not px then
      px = char(r, g, b, alpha)
      cache[key] = px
    end
    buffer[i] = px
  end

  for _ = 1, 700 do
    local bw = 2 + (random() % 24)
    local bh = 1 + (random() % 10)
    local x = random() % (w - bw)
    local y = random() % (h - bh)
    local r = random() % 256
    local g = random() % 256
    local b = random() % 256
    local a = floor(alpha * (0.3 + (random() % 71) / 100))
    local key = r * 16777216 + g * 65536 + b * 256 + a
    local px = cache[key] or char(r, g, b, a)
    cache[key] = px
    fill_block(buffer, w, h, x, y, bw, bh, px)
  end

  for i = 1, 20 do
    local y = random() % h
    local a = floor(alpha * (0.3 + (random() % 71) / 100))
    local r = random() % 256
    local g = random() % 256
    local b = random() % 256
    local key = r * 16777216 + g * 65536 + b * 256 + a
    local px = cache[key] or char(r, g, b, a)
    cache[key] = px
    fill_block(buffer, w, h, 0, y, w, 1, px)
  end

  for _ = 1, 40 do
    local x = random() % w
    local y = random() % h
    local len = 10 + (random() % 40)
    local a = floor(alpha * (0.3 + (random() % 71) / 100))
    local r = random() % 256
    local g = random() % 256
    local b = random() % 256
    local key = r * 16777216 + g * 65536 + b * 256 + a
    local px = cache[key] or char(r, g, b, a)
    cache[key] = px

    for i = 0, len do
      local dx = (x + i) % w
      local dy = (y + i) % h
      local idx = dy * w + dx + 1
      buffer[idx] = px
    end
  end

  canvas.pixels = concat(buffer, "", 1, total)
end

function NoiseEffect:teardown()
  canvas:clear()

  self.buffer = nil
  self.cache = nil
  self.callback = nil

  self.loop = function() end
end

return NoiseEffect:new()
