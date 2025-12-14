local camera = {}

local position = Vec2.new(0, 0)
local speed = 1

function camera.calculate(delta)
  local player = statemanager:player(Player.one)

  if player:on(Controller.up) then
    position.y = position.y - speed
  end
  if player:on(Controller.down) then
    position.y = position.y + speed
  end
  if player:on(Controller.left) then
    position.x = position.x - speed
  end
  if player:on(Controller.right) then
    position.x = position.x + speed
  end

  return position
end

return camera
