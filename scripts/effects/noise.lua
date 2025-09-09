local FastPentagram = {}
FastPentagram.__index = FastPentagram

local char, concat, floor, abs, cos, sin, pi =
  string.char, table.concat, math.floor, math.abs, math.cos, math.sin, math.pi

function FastPentagram:new(width, height)
  local w, h = width or 480, height or 270
  local self = setmetatable({}, FastPentagram)
  self.canvas = engine:canvas()
  self.width, self.height = w, h
  self.pixel_count = w * h
  self.buffer = {}
  self.EMPTY = char(0, 0, 0, 0)
  self.RED = char(255, 0, 0, 255)

  self.start_time = moment()
  self.scale = h * 0.4
  self.line_thickness = 2

  -- ordem de conexão do pentagrama (5 pontos)
  self.edges = {
    { 1, 3 },
    { 3, 5 },
    { 5, 2 },
    { 2, 4 },
    { 4, 1 }, -- estrela
    { 1, 2 },
    { 2, 3 },
    { 3, 4 },
    { 4, 5 },
    { 5, 1 }, -- pentágono externo
  }
  return self
end

function FastPentagram:init() end

function FastPentagram:plot(x, y)
  if x < 0 or x >= self.width or y < 0 or y >= self.height then
    return
  end
  local idx = y * self.width + x + 1
  self.buffer[idx] = self.RED
end

function FastPentagram:draw_thick_point(x, y)
  local t = self.line_thickness
  for dy = -t, t do
    local yy = y + dy
    for dx = -t, t do
      self:plot(x + dx, yy)
    end
  end
end

function FastPentagram:draw_line(x0, y0, x1, y1)
  x0 = floor(x0)
  y0 = floor(y0)
  x1 = floor(x1)
  y1 = floor(y1)

  local dx = abs(x1 - x0)
  local dy = abs(y1 - y0)
  local sx = x0 < x1 and 1 or -1
  local sy = y0 < y1 and 1 or -1
  local err = dx - dy

  while true do
    self:draw_thick_point(x0, y0)
    if x0 == x1 and y0 == y1 then
      return
    end
    local e2 = err + err
    if e2 > -dy then
      err = err - dy
      x0 = x0 + sx
    end
    if e2 < dx then
      err = err + dx
      y0 = y0 + sy
    end
  end
end

function FastPentagram:loop()
  local elapsed = (moment() - self.start_time) * 0.001
  local angle_y = elapsed * 0.8
  local cy = self.height * 0.5
  local cx = self.width * 0.5
  local angle_step = pi * 0.4
  local phase_offset = pi * 1.5

  -- limpa o frame reutilizando a mesma string vazia
  local buf = self.buffer
  local total = self.pixel_count
  for i = 1, total do
    buf[i] = self.EMPTY
  end

  -- projeção simples com rotação em Y
  local c = cos(angle_y)
  local s = sin(angle_y)
  local scale = self.scale

  local projected = {}
  for i = 0, 4 do
    local a = angle_step * i + phase_offset
    local x = cos(a)
    local y = -sin(a)
    local z = 0

    local xr = x * c - z * s
    local zr = x * s + z * c
    local fov = 1 / (1 + zr * 0.5)

    projected[i + 1] = { x = cx + xr * scale * fov, y = cy + y * scale * fov }
  end

  for _, e in ipairs(self.edges) do
    local a = projected[e[1]]
    local b = projected[e[2]]
    self:draw_line(a.x, a.y, b.x, b.y)
  end

  self.canvas.pixels = concat(buf, "", 1, total)
end

function FastPentagram:teardown() end

return FastPentagram:new()
