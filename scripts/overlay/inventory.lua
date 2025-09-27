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

  for i = 1, #self.objects do
    self.objects[i].y = self.layout.y
  end

  self.is_animating = false
  self.start_y = self.layout.y
  self.delta = 0
  self.progress = 0
  return self
end

function M:motion(x, y)
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
      self.objects[i].y = self.layout.y
    end

    self.is_animating = false
    return
  end

  local current_y = self.start_y + self.delta * ratio

  self.layout.y = current_y
  self.character.y = current_y

  for i = 1, #self.objects do
    self.objects[i].y = current_y
  end
end

return M
