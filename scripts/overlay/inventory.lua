local Inventory = {}
Inventory.__index = Inventory

local ANIMATION_DURATION = 0.2

function Inventory.new(object, character)
    local self = setmetatable({}, Inventory)
    self.object              = object
    self.character           = character
    self.original_y_position = object.y
    self.object.y            = self.original_y_position + 40
    self.character.y         = self.object.y
    self.is_animating        = false
    self.start_y             = self.object.y
    self.delta               = 0
    self.progress            = 0
    return self
end

function Inventory:on_motion(x, y)
    if self.is_animating then
        return
    end

    local target_y = y > 180 and self.original_y_position or self.original_y_position + 40

    if target_y == self.object.y then
        return
    end

    self.start_y     = self.object.y
    self.delta       = target_y - self.start_y
    self.progress    = 0
    self.is_animating = true
end

function Inventory:update(delta)
    if not self.is_animating then
        return
    end

    self.progress = self.progress + delta

    local ratio = self.progress / ANIMATION_DURATION

    if ratio >= 1 then
        self.object.y = self.start_y + self.delta
        self.character.y = self.object.y
        self.is_animating = false
        return
    end

    self.object.y = self.start_y + self.delta * ratio
    self.character.y = self.object.y
end

return Inventory
