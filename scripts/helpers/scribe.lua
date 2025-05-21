local fontfactory = engine:fontfactory()
local overlay = engine:overlay()

local Writer = {}
Writer.__index = Writer

local INTERVAL = 0.08

function Writer.new()
  local self = setmetatable({}, Writer)
  self.label = overlay:create(WidgetType.label)
  local font = fontfactory:get("test")
  font.effect = FontEffect.fadein
  self.label.font = font
  self.text = ""
  self.index = 0
  self.accumulator = 0
  self.is_writing = false
  self.finish_delay = 0
  self.finish_countdown = nil
  self.callback = nil
  self.x, self.y = 0, 0
  return self
end

function Writer:on_finish(timeout, callback)
  assert(type(timeout) == "number")
  assert(type(callback) == "function")
  self.finish_delay = timeout
  self.callback = callback
end

function Writer:clear()
  self.index = 0
  self.text = ""
  self.accumulator = 0
  self.is_writing = false
  self.finish_countdown = nil
  self.callback = nil
  self.label:clear()
end

function Writer:write(text, x, y)
  assert(type(text) == "string")
  assert(type(x) == "number")
  assert(type(y) == "number")
  self.text = text
  self.index = 0
  self.accumulator = 0
  self.is_writing = true
  self.finish_countdown = nil
  self.x, self.y = x, y
  self.label:set("", x, y)
end

function Writer:loop(delta)
  if self.is_writing then
    self.accumulator = self.accumulator + delta
    while self.accumulator >= INTERVAL do
      self.accumulator = self.accumulator - INTERVAL
      self.index = self.index + 1
      local substr = self.text:sub(1, self.index)
      self.label:set(substr, self.x, self.y)
      if self.index >= #self.text then
        self.is_writing = false
        self.finish_countdown = moment() + self.finish_delay
        break
      end
    end
  end

  if not self.is_writing and self.finish_countdown then
    if moment() >= self.finish_countdown then
      local cb = self.callback
      self:clear()
      return cb()
    end
  end
end

return Writer.new()
