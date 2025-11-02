local M = {}
M.__index = M

local ANIMATION_DURATION = 0.2

function M.new(layout, character, objects)
  local self = setmetatable({}, M)

  local refs = setmetatable({ layout = layout, character = character }, { __mode = "v" })
  self.refs = refs

  self.objects = setmetatable(objects, { __mode = "v" })
  self.original_y_position = layout.y

  refs.layout.y = self.original_y_position + 40
  refs.character.y = refs.layout.y

  self.target = nil
  self.x_offset = 0
  self.y_offset = 0
  self.x_origin = 0
  self.y_origin = 0

  for i = 1, #self.objects do
    local obj = self.objects[i]
    if obj then
      obj.y = refs.layout.y
    end
  end

  local weak_self = setmetatable({ self = self }, { __mode = "v" })

  for i = 1, #self.objects do
    local idx = i
    local obj = self.objects[idx]
    if obj then
      obj:on_touch(function(_, x, y)
        local s = weak_self.self
        if not s then
          return
        end
        local objects = s.objects
        if not objects then
          return
        end
        local o = objects[idx]
        if not o then
          return
        end
        s.x_origin = o.x
        s.y_origin = o.y
        s.target = idx
        s.x_offset = x - s.x_origin
        s.y_offset = y - s.y_origin
      end)
    end
  end

  self.is_animating = false
  self.start_y = refs.layout.y
  self.delta = 0
  self.progress = 0
  return self
end

function M:motion(x, y)
  if self.target then
    local o = self.objects and self.objects[self.target]
    if o then
      o.placement = {
        x = x - self.x_offset,
        y = y - self.y_offset,
      }
    end
  end

  if self.is_animating then
    return
  end

  local refs = self.refs
  local layout = refs and refs.layout
  if not layout then
    return
  end

  local target_y = y > 180 and self.original_y_position or self.original_y_position + 40

  if target_y == layout.y then
    return
  end

  self.start_y = layout.y
  self.delta = target_y - self.start_y
  self.progress = 0
  self.is_animating = true
end

function M:loop(delta)
  if not self.is_animating then
    return
  end

  local refs = self.refs
  local layout = refs and refs.layout
  local character = refs and refs.character
  if not layout or not character then
    self.is_animating = false
    return
  end

  self.progress = self.progress + delta
  local ratio = self.progress / ANIMATION_DURATION

  if ratio >= 1 then
    layout.y = self.start_y + self.delta
    character.y = layout.y

    for i = 1, #self.objects do
      if self.target ~= i then
        local obj = self.objects[i]
        if obj then
          obj.y = layout.y
        end
      end
    end

    self.is_animating = false
    return
  end

  local current_y = self.start_y + self.delta * ratio

  layout.y = current_y
  character.y = current_y

  for i = 1, #self.objects do
    if self.target ~= i then
      local obj = self.objects[i]
      if obj then
        obj.y = current_y
      end
    end
  end
end

function M:teardown()
  if self.target ~= nil and self.objects then
    local obj = self.objects[self.target]
    if obj then
      obj.placement = {
        x = 0,
        y = self.y_origin,
      }
    end
    self.target = nil
  end

  if self.objects then
    for i = 1, #self.objects do
      local obj = self.objects[i]
      if obj then
        obj:on_touch(nil)
      end
    end
  end

  local refs = self.refs
  if refs and refs.layout then
    refs.layout.y = self.original_y_position
  end

  self.is_animating = false
  self.objects = nil
  self.refs = nil
end

function M:release()
  if self.target and self.objects then
    local object = self.objects[self.target]
    if object then
      object.visible = false
    end
  end
  self.target = nil
end

M.__index = function(instance, key)
  if key == "dragging" then
    local target = instance.target
    if not target then
      return nil
    end
    local objects = instance.objects
    if not objects then
      return nil
    end
    local object = objects[target]
    if not object then
      return nil
    end
    return object.kind
  end
  return rawget(M, key)
end

return M
