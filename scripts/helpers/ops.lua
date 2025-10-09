local M = {}

function M.set(observable, value)
  if value == nil then
    value = 0
  end
  observable:set(value)
end

local function add(observable, delta)
  local value = observable.value
  if value == nil then
    observable:set(delta)
    return
  end
  observable:set(value + delta)
end

function M.incr(observable)
  add(observable, 1)
end

function M.incrby(observable, number)
  add(observable, number)
end

function M.decr(observable)
  add(observable, -1)
end

function M.decrby(observable, number)
  add(observable, -number)
end

function M.getset(observable, new)
  local old = observable.value
  observable:set(new)
  return old
end

function M.setnx(observable, value)
  if observable.value == nil then
    observable:set(value)
    return true
  end
  return false
end

return M
