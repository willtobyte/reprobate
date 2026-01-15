local camera = {}

local position = Quad.new(0, 0, viewport.width, viewport.height)
local speed = 1

function camera.calculate(delta)
  if keyboard.up then
    position.y = position.y - speed
  end
  if keyboard.down then
    position.y = position.y + speed
  end
  if keyboard.left then
    position.x = position.x - speed
  end
  if keyboard.right then
    position.x = position.x + speed
  end

  return position
end

return camera
