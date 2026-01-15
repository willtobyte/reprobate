local camera = {}

local position = Quad.new(0, 0, viewport.width, viewport.height)
local speed = 1

function camera.calculate(delta)
  if Keyboard.up then
    position.y = position.y - speed
  end
  if Keyboard.down then
    position.y = position.y + speed
  end
  if Keyboard.left then
    position.x = position.x - speed
  end
  if Keyboard.right then
    position.x = position.x + speed
  end

  return position
end

return camera
