local M = {}

local function add(observable, delta)
  local v = observable.value
  if v == nil then
    observable:set(delta)
    return
  end
  observable:set(v + delta)
end

function M.incr(observable)
  add(observable, 1)
end

function M.incrby(observable, n)
  add(observable, n)
end

function M.decr(observable)
  add(observable, -1)
end

function M.decrby(observable, n)
  add(observable, -n)
end

function M.getset(observable, new_value)
  local old = observable.value
  observable:set(new_value)
  return old
end

function M.setnx(observable, v)
  if observable.value == nil then
    observable:set(v)
    return true
  end
  return false
end

return M
