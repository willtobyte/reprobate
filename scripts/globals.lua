function transition(options)
  if options.destroy then
    for _, name in ipairs(options.destroy) do
      scenemanager:destroy(name)
    end
  end

  if options.register then
    for _, name in ipairs(options.register) do
      scenemanager:register(name)
    end
  end
end

---@class State
---@field [string] any
state = { system = {} }

local function _wrap_key(key)
  local scene = scenemanager.current
  assert(key ~= nil, "key must not be nil")
  return scene .. "/" .. key
end

setmetatable(state.system, {
  __newindex = function(t, k, v)
    cassette:set("system/" .. k, v)
  end,
  __index = function(t, k)
    return cassette:get("system/" .. k, nil)
  end,
})

setmetatable(state, {
  __newindex = function(t, k, v)
    cassette:set(_wrap_key(k), v)
  end,
  __index = function(t, k)
    return cassette:get(_wrap_key(k), nil)
  end,
})

local function dense(t)
  if type(t) ~= "table" then
    return nil
  end

  local count = 0
  for i = 1, #t do
    if t[i] == nil then
      return nil
    end
    count = count + 1
  end

  for k, _ in pairs(t) do
    if type(k) ~= "number" or k < 1 or k > count or k ~= math.floor(k) then
      return nil
    end
  end

  return count > 0 and count or nil
end

function any(t, selector)
  if selector == nil then
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

  if type(selector) == "string" then
    for _, v in pairs(t) do
      if type(v) == "table" and v[selector] then
        return true
      end
    end
    return false
  end

  if type(selector) == "function" then
    for k, v in pairs(t) do
      if selector(v, k) then
        return true
      end
    end
    return false
  end

  error("invalid selector for any: " .. tostring(selector))
end

function all(t, selector)
  if selector == nil then
    for _, v in pairs(t) do
      if not v then
        return false
      end
    end
    return true
  end

  if type(selector) == "string" then
    for _, v in pairs(t) do
      if type(v) ~= "table" or not v[selector] then
        return false
      end
    end
    return true
  end

  if type(selector) == "function" then
    for k, v in pairs(t) do
      if not selector(v, k) then
        return false
      end
    end
    return true
  end

  error("invalid selector for all: " .. tostring(selector))
end

jump = {}

function jump.to(name, delay)
  assert(type(name) == "string" and #name > 0, "scene name must be a non-empty string")
  assert(delay == nil or (type(delay) == "number" and delay >= 0), "delay must be a non-negative number")

  delay = delay or 100
  return function(...)
    timermanager:singleshot(delay, function()
      scenemanager:set(name)
    end)
  end
end
