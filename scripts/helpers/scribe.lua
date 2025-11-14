local scribe = {}

local INTERVAL = 0.08

-- Internal state
local label = nil
local text = ""
local index = 0
local accumulator = 0
local is_writing = false
local finish_delay = 0
local finish_countdown = nil
local callback = nil
local x, y = 0, 0

local function initialize()
  if not label then
    label = overlay:create(WidgetType.label)
    local font = fontfactory:get("rpgfont")
    label.font = font
    label.effect = FontEffect.fadein
  end
end

function scribe.on_finish(timeout, cb)
  assert(type(timeout) == "number")
  assert(type(cb) == "function")
  finish_delay = timeout
  callback = cb
end

function scribe.clear()
  index = 0
  text = ""
  accumulator = 0
  is_writing = false
  finish_countdown = nil
  callback = nil
  if label then
    label:clear()
  end
end

function scribe.write(txt, px, py)
  assert(type(txt) == "string")
  assert(type(px) == "number")
  assert(type(py) == "number")
  initialize()
  if not label then
    return
  end
  text = txt
  index = 0
  accumulator = 0
  is_writing = true
  finish_countdown = nil
  x, y = px, py
  label:set("", x, y)
end

function scribe.loop(delta)
  if not label then
    return
  end
  if is_writing then
    accumulator = accumulator + delta
    while accumulator >= INTERVAL do
      accumulator = accumulator - INTERVAL
      index = index + 1
      local substr = text:sub(1, index)
      label:set(substr, x, y)
      if index >= #text then
        is_writing = false
        finish_countdown = moment() + finish_delay
        break
      end
    end
  end

  if not is_writing and finish_countdown then
    if moment() >= finish_countdown then
      local cb = callback
      scribe.clear()
      if cb then
        return cb()
      end
    end
  end
end

function scribe.say(msg, px, py, ms)
  scribe.clear()
  scribe.write(msg, px or 3, py or 3)
  scribe.on_finish(ms or 6000, function()
    scribe.clear()
  end)
end

return scribe
