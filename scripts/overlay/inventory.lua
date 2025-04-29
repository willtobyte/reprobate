local Inventory = {}
Inventory.__index = Inventory

local ANIMATION_DURATION = 0.2

function Inventory.new(object)
    local self = setmetatable({}, Inventory)
    self.object                = object
    self.original_y_position   = object.y
    self.object.y              = self.original_y_position + 40
    self.is_animation_active   = false
    self.start_y               = self.object.y
    self.delta                 = 0
    self.progress              = 0
    return self
end

function Inventory:on_motion(x, y)
    if self.is_animation_active then return end

    local target = y > 200
                   and self.original_y_position
                   or self.original_y_position + 40

    if target == self.object.y then return end

    self.start_y             = self.object.y
    self.delta               = target - self.start_y
    self.progress            = 0
    self.is_animation_active = true
end

function Inventory:update(delta)
    if not self.is_animation_active then return end

    self.progress = self.progress + delta
    local ratio = self.progress / ANIMATION_DURATION

    if ratio >= 1 then
        self.object.y              = self.start_y + self.delta
        self.is_animation_active   = false
        return
    end

    self.object.y = self.start_y + self.delta * ratio
end

return Inventory
