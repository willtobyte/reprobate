local fontfactory = engine:fontfactory()
local overlay = engine:overlay()
local timemanager = engine:timermanager()

local writter = {}
writter.__index = writter

function writter:new()
  local instance = setmetatable({}, writter)

  instance.label = overlay:create(WidgetType.label)
  instance.label.font = fontfactory:get("fixedsys")

  instance.text = ""
  instance.index = 0

  instance.tick_timer = nil
  instance.finish_timer = nil

  instance.timeout = 0
  instance.callback = nil

  return instance
end

function writter:on_finish(timeout, callback)
  assert(type(timeout) == "number")
  assert(type(callback) == "function")

  self.timeout = timeout
  self.callback = callback
end

function writter:clear()
  self.index = 0
  self.label:clear()

  if self.tick_timer then
    timemanager:clear(self.tick_timer)
    self.tick_timer = nil
  end

  if self.finish_timer then
    timemanager:clear(self.finish_timer)
    self.finish_timer = nil
  end
end

function writter:write(text, x, y)
  assert(type(text) == "string")
  assert(type(x) == "number")
  assert(type(y) == "number")

  if self.tick_timer then
    timemanager:clear(self.tick_timer)
    self.tick_timer = nil
  end

  if self.finish_timer then
    timemanager:clear(self.finish_timer)
    self.finish_timer = nil
  end

  self.text = text
  self.index = 0
  self.label:set("", x, y)

  local function tick()
    self.index = self.index + 1
    local substring = self.text:sub(1, self.index)
    self.label:set(substring, x, y)

    if self.index >= #self.text then
      timemanager:clear(self.tick_timer)
      self.tick_timer = nil

      if self.callback then
        self.finish_timer = timemanager:singleshot(
          self.timeout,
          function()
            self.callback()
            self.finish_timer = nil
          end
        )
      end
    end
  end

  self.tick_timer = timemanager:set(100, tick)
end

return writter:new()
