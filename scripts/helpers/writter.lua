local writter = {}

local fontfactory = engine:fontfactory()
local overlay = engine:overlay()
local timermanager = engine:timermanager()

local pool = {}

pool.label = nil
pool.timer = nil
pool.timeout = nil
pool.callback = nil

pool.label = overlay:create(WidgetType.label)
pool.label.font = fontfactory:get("evilvampire")

function writter.on_finish(timeout, callback)
  assert(type(timeout) == "number", "timeout must be a number")
  assert(type(callback) == "function", "callback must be a function")

  pool.timeout = timeout
  pool.callback = callback
end

function writter.clear()
  pool.index = 0
  pool.label:clear()
end

function writter.write(text, x, y)
  if pool.timer then
    timermanager:clear(pool.timer)
    pool.timer = nil
  end

  pool.text = text
  pool.index = 0
  pool.label:set("", x, y)

  local function tick()
    pool.index = pool.index + 1
    pool.label:set(text:sub(1, pool.index), x, y)
    if pool.index >= #text then
      timermanager:clear(pool.timer)
      pool.timer = nil
      if pool.callback then
        print('call callback')
        timermanager:singleshot(pool.timeout, pool.callback)
      end
    end
  end

  local timeout = 100
  pool.timer = timermanager:set(timeout, tick)
end

return writter
