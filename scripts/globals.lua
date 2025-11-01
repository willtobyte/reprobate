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

local pool = {}

local state = { system = {} }

local function _wrap_key(k)
  local scene = scenemanager:get()
  return scene.name .. "/" .. k
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

_G.state = state

_G.pool = pool

function any(t)
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

function all(t)
  for _, v in pairs(t) do
    if not v then
      return false
    end
  end
  return true
end
