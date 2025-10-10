local M = {}

local unpack = table.unpack or unpack
local huge = math.huge
local type = type

function M.any(t)
  for i = 1, #t do
    if t[i] then
      return true
    end
  end
  return false
end

function M.all(t)
  for _, v in pairs(t) do
    if not v then
      return false
    end
  end
  return true
end

function M.sum(t, start)
  local s = start or 0
  for i = 1, #t do
    s = s + t[i]
  end
  return s
end

function M.min(t)
  local n = #t
  if n == 0 then
    return nil
  end
  local m = t[1]
  local mi = 1
  for i = 2, n do
    local v = t[i]
    if v < m then
      m = v
      mi = i
    end
  end
  return m, mi
end

function M.max(t)
  local n = #t
  if n == 0 then
    return nil
  end
  local m = t[1]
  local mi = 1
  for i = 2, n do
    local v = t[i]
    if v > m then
      m = v
      mi = i
    end
  end
  return m, mi
end

function M.count(t, value)
  local c = 0
  for i = 1, #t do
    if t[i] == value then
      c = c + 1
    end
  end
  return c
end

function M.enumerate(t, start)
  local i = (start or 1) - 1
  local n = #t
  return function()
    i = i + 1
    if i > n then
      return
    end
    return i, t[i]
  end
end

function M.range(a, b, step)
  local startv, stopv, stepv
  if b == nil then
    startv, stopv, stepv = 0, a, 1
  end
  if b ~= nil then
    startv, stopv, stepv = a, b, (step or 1)
  end
  if stepv == 0 then
    error("range: step must not be zero")
  end
  local i = startv - stepv
  if stepv > 0 then
    return function()
      i = i + stepv
      if i >= stopv then
        return
      end
      return i
    end
  end

  return function()
    i = i + stepv
    if i <= stopv then
      return
    end
    return i
  end
end

function M.zip(...)
  local arrays = { ... }
  local k = #arrays
  if k == 0 then
    return function()
      return
    end
  end
  local n = huge
  for i = 1, k do
    local m = #arrays[i]
    if m < n then
      n = m
    end
  end
  local i = 0
  return function()
    i = i + 1
    if i > n then
      return
    end
    local out = {}
    for j = 1, k do
      out[j] = arrays[j][i]
    end
    return unpack(out, 1, k)
  end
end

function M.map(func, t)
  local n = #t
  local out = {}
  for i = 1, n do
    out[i] = func(t[i], i)
  end
  return out
end

function M.filter(func, t)
  local out = {}
  local j = 1
  for i = 1, #t do
    local v = t[i]
    if func(v, i) then
      out[j] = v
      j = j + 1
    end
  end
  return out
end

function M.reduce(func, t, init)
  local n = #t
  local i = 1
  local acc = init
  if acc == nil then
    if n == 0 then
      error("reduce: empty table with no initial value")
    end
    acc = t[1]
    i = 2
  end
  for idx = i, n do
    acc = func(acc, t[idx], idx)
  end
  return acc
end

return M
