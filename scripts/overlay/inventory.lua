local Inventory = {}

local ANIMATION_DURATION = 0.2

function Inventory.new(layout, character, objects)
  local original_y_position = layout.y
  layout.y = original_y_position + 40
  character.y = layout.y

  local target = nil
  local x_offset = 0
  local y_offset = 0
  local x_origin = 0
  local y_origin = 0

  local is_animating = false
  local start_y = layout.y
  local delta = 0
  local progress = 0

  for i = 1, #objects do
    objects[i].y = layout.y

    objects[i]:on_touch(function(x, y)
      local object = objects[i]
      x_origin = object.x
      y_origin = object.y
      target = i
      x_offset = x - x_origin
      y_offset = y - y_origin
    end)
  end

  local function motion(x, y)
    if target then
      objects[target].position = {
        x = x - x_offset,
        y = y - y_offset,
      }
    end

    if is_animating then
      return
    end

    local target_y = y > 180 and original_y_position or original_y_position + 40

    if target_y == layout.y then
      return
    end

    start_y = layout.y
    delta = target_y - start_y
    progress = 0
    is_animating = true
  end

  local function loop(dt)
    if not is_animating then
      return
    end

    progress = progress + dt

    local ratio = progress / ANIMATION_DURATION

    if ratio >= 1 then
      layout.y = start_y + delta
      character.y = layout.y

      for i = 1, #objects do
        if target ~= i then
          objects[i].y = layout.y
        end
      end

      is_animating = false
      return
    end

    local current_y = start_y + delta * ratio

    layout.y = current_y
    character.y = current_y

    for i = 1, #objects do
      if target ~= i then
        objects[i].y = current_y
      end
    end
  end

  local function teardown()
    if target ~= nil then
      objects[target].position = {
        x = 0,
        y = y_origin,
      }

      target = nil
    end

    layout.y = original_y_position
    character.y = original_y_position

    for i = 1, #objects do
      objects[i]:on_touch(nil)
      objects[i].y = original_y_position
    end

    objects = nil
    layout = nil
    character = nil
  end

  local function release()
    if target then
      local object = objects[target]
      if object then
        object.visible = false
      end
    end

    target = nil
  end

  local instance = {
    motion = motion,
    loop = loop,
    teardown = teardown,
    release = release,
  }

  setmetatable(instance, {
    __index = function(t, key)
      if key == "dragging" then
        if not target then
          return nil
        end
        if not objects then
          return nil
        end
        local object = objects[target]
        if not object then
          return nil
        end
        return object.kind
      end
      return rawget(t, key)
    end,
  })

  return instance
end

return Inventory
