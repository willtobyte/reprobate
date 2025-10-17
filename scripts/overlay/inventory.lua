local M = {}
M.__index = M

local ANIMATION_DURATION = 0.2

function M.new(layout, character, objects)
  local self = setmetatable({}, M)
  self.layout = layout
  self.character = character
  self.objects = objects
  self.original_y_position = layout.y
  self.layout.y = self.original_y_position + 40
  self.character.y = self.layout.y
  self.target = nil
  self.x_offset = 0
  self.y_offset = 0
  self.x_orig = 0
  self.y_orig = 0

  for i = 1, #self.objects do
    self.objects[i].y = self.layout.y

    self.objects[i]:on_touch(function(_, x, y)
      local object = self.objects[i]
      self.x_orig = object.x
      self.y_orig = object.y

      self.target = i
      self.x_offset = x - self.x_orig
      self.y_offset = y - self.y_orig
    end)
  end

  self.is_animating = false
  self.start_y = self.layout.y
  self.delta = 0
  self.progress = 0
  return self
end

function M:motion(x, y)
  if self.target then
    self.objects[self.target].placement = {
      x = x - self.x_offset,
      y = y - self.y_offset,
    }
  end

  if self.is_animating then
    return
  end

  local target_y = y > 180 and self.original_y_position or self.original_y_position + 40

  if target_y == self.layout.y then
    return
  end

  self.start_y = self.layout.y
  self.delta = target_y - self.start_y
  self.progress = 0
  self.is_animating = true
end

function M:loop(delta)
  if not self.is_animating then
    return
  end

  self.progress = self.progress + delta

  local ratio = self.progress / ANIMATION_DURATION

  if ratio >= 1 then
    self.layout.y = self.start_y + self.delta
    self.character.y = self.layout.y

    for i = 1, #self.objects do
      if self.target ~= i then
        self.objects[i].y = self.layout.y
      end
    end

    self.is_animating = false
    return
  end

  local current_y = self.start_y + self.delta * ratio

  self.layout.y = current_y
  self.character.y = current_y

  for i = 1, #self.objects do
    if self.target ~= i then
      self.objects[i].y = current_y
    end
  end
end

function M:teardown()
  if self.target ~= nil then
    self.objects[self.target].x = self.x_orig
    self.objects[self.target].y = self.y_orig
    self.target = nil
  end

  for i = 1, #self.objects do
    self.objects[i]:on_touch(nil)
  end

  self.objects = nil

  self.layout.y = self.start_y
  self.layout = nil
  self.character = nil
end

function M:release()
  if self.target then
    local object = self.objects[self.target]
    if object then
      object.visible = false
    end
  end

  self.target = nil
end

M.__index = function(t, k)
  if k == "dragging" then
    local i = t.target
    if not i then
      return nil
    end
    local objects = t.objects
    if not objects then
      return nil
    end
    local object = objects[i]
    if not object then
      return nil
    end
    return object.kind
  end
  return rawget(M, k)
end

return M
