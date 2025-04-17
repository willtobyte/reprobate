local writter = {}

local fontfactory = engine:fontfactory()
local overlay = engine:overlay()
local timermanager = engine:timermanager()

local label = overlay:create(WidgetType.label)
label.font = fontfactory:get("evilvampire")

local text = ""
local index = 0
local timer = nil
local timeout = nil
local callback = nil

function writter.on_finish(t, cb)
  assert(type(t) == "number", "timeout must be a number")
  assert(type(cb) == "function", "callback must be a function")
  timeout = t
  callback = cb
end

function writter.clear()
  index = 0
  label:clear()
end

function writter.write(t, x, y)
  assert(type(t) == "string", ("scribe.write: expected string, got %s"):format(type(t)))

  if timer then
    timermanager:clear(timer)
  end

  text = t
  index = 0
  label:set("", x, y)

  local function tick()
    index = index + 1
    label:set(text:sub(1, index), x, y)

    if index >= #text then
      timermanager:clear(timer)
      timer = nil
      if callback then
        timermanager:singleshot(timeout, callback)
      end
    end
  end

  timer = timermanager:set(100, tick)
end

return writter
