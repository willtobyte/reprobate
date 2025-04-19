local fontfactory = engine:fontfactory()
local overlay = engine:overlay()
local timermanager = engine:timermanager()

local Writter = {}
Writter.__index = Writter

function Writter:new()
  local self = setmetatable({}, Writter)

  self.fontfactory = fontfactory
  self.overlay = overlay
  self.timermanager = timermanager

  self.label = self.overlay:create(WidgetType.label)
  self.label.font = self.fontfactory:get("evilvampire")

  self.text = ""
  self.index = 0
  self.timer = nil
  self.timeout = nil
  self.callback = nil

  return self
end

function Writter:on_finish(timeout, callback)
  assert(type(timeout) == "number", "timeout must be a number")
  assert(type(callback) == "function", "callback must be a function")
  self.timeout = timeout
  self.callback = callback
end

function Writter:clear()
  self.index = 0
  self.label:clear()
end

function Writter:write(text, x, y)
  assert(type(text) == "string", ("Writter:write: expected string, got %s"):format(type(t)))
  assert(type(x) == "number", ("Writter:write: expected number for x, got %s"):format(type(x)))
  assert(type(y) == "number", ("Writter:write: expected number for y, got %s"):format(type(y)))

  if self.timer then
    self.timermanager:clear(self.timer)
  end

  self.text = text
  self.index = 0
  self.label:set("", x, y)

  local function tick()
    self.index = self.index + 1
    self.label:set(self.text:sub(1, self.index), x, y)

    if self.index >= #self.text then
      self.timermanager:clear(self.timer)
      self.timer = nil
      if self.callback then
        self.timermanager:singleshot(self.timeout, self.callback)
      end
    end
  end

  self.timer = self.timermanager:set(100, tick)
end

local instance = Writter:new()
return instance
