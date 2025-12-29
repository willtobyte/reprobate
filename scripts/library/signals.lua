local _signals = {}
local _id_map = {}
local _next_id = 0

local function emit_signal(name)
  return function(...)
    local slots = _signals[name]
    if not slots then
      return
    end
    for i = 1, #slots do
      slots[i](...)
    end
  end
end

local function connect_slot(name)
  return function(callback)
    local id = _next_id
    _next_id = _next_id + 1

    local slots = _signals[name]
    if not slots then
      slots = {}
      _signals[name] = slots
    end

    slots[#slots + 1] = callback
    _id_map[id] = { name = name, callback = callback }

    return id
  end
end

emit = setmetatable({}, {
  __index = function(_, name)
    return emit_signal(name)
  end,
})
slot = setmetatable({}, {
  __index = function(_, name)
    return connect_slot(name)
  end,
})

function disconnect(id)
  local entry = _id_map[id]
  if not entry then
    return false
  end

  local slots = _signals[entry.name]
  if slots then
    for i = #slots, 1, -1 do
      if slots[i] == entry.callback then
        table.remove(slots, i)
        break
      end
    end
  end

  _id_map[id] = nil
  return true
end

function clear(name)
  _signals[name] = nil
  for id, entry in pairs(_id_map) do
    if entry.name == name then
      _id_map[id] = nil
    end
  end
end
