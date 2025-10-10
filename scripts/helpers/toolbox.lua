local M = {}

local unpack = table.unpack or unpack
local huge = math.huge
local next = next

local function dense(t)
  local n = #t
  for i = 1, n do
    if t[i] == nil then
      return nil
    end
  end
  return n
end

function M.any(t)
  local n = dense(t)
  if n then
    for i = 1, n do
      if t[i] then
        return true
      end
    end
    return false
  end
  for _, v in pairs(t) do
    if v then
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
  local n = dense(t)
  if n then
    for i = 1, n do
      s = s + t[i]
    end
    return s
  end
  for _, v in pairs(t) do
    s = s + v
  end
  return s
end

function M.min(t)
  local n = dense(t)
  if n and n == 0 then
    return nil
  end
  if n then
    local m = t[1]
    if m == nil then
      return nil
    end
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
  local first_k, first_v = next(t)
  if first_k == nil then
    return nil
  end
  local m, mk = first_v, first_k
  for k, v in pairs(t) do
    if v < m then
      m = v
      mk = k
    end
  end
  return m, mk
end

function M.max(t)
  local n = dense(t)
  if n and n == 0 then
    return nil
  end
  if n then
    local m = t[1]
    if m == nil then
      return nil
    end
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
  local first_k, first_v = next(t)
  if first_k == nil then
    return nil
  end
  local m, mk = first_v, first_k
  for k, v in pairs(t) do
    if v > m then
      m = v
      mk = k
    end
  end
  return m, mk
end

function M.count(t, value)
  local c = 0
  local n = dense(t)
  if n then
    for i = 1, n do
      if t[i] == value then
        c = c + 1
      end
    end
    return c
  end
  for _, v in pairs(t) do
    if v == value then
      c = c + 1
    end
  end
  return c
end

function M.enumerate(t, start)
  local n = dense(t) or 0
  local i = (start or 1) - 1
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
    local di = dense(arrays[i])
    if not di then
      return function()
        return
      end
    end
    if di < n then
      n = di
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
  local n = dense(t)
  if n then
    local out = {}
    for i = 1, n do
      out[i] = func(t[i], i)
    end
    return out
  end
  local out, j = {}, 1
  for k, v in pairs(t) do
    out[j] = func(v, k)
    j = j + 1
  end
  return out
end

function M.filter(func, t)
  local out, j = {}, 1
  local n = dense(t)
  if n then
    for i = 1, n do
      local v = t[i]
      if func(v, i) then
        out[j] = v
        j = j + 1
      end
    end
    return out
  end
  for k, v in pairs(t) do
    if func(v, k) then
      out[j] = v
      j = j + 1
    end
  end
  return out
end

function M.reduce(func, t, init)
  local n = dense(t)
  if n then
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
  local acc = init
  local first = true
  for k, v in pairs(t) do
    if acc == nil then
      if first then
        acc = v
        first = false
      end
    else
      acc = func(acc, v, k)
    end
  end
  if acc == nil then
    error("reduce: empty table with no initial value")
  end
  return acc
end

return M
