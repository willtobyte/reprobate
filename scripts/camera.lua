local camera = {}

function camera.calculate(delta)
  local x, y, vw, vh = 0, 0, 100, 200 -- TODO
  return Rectangle.new(x, y, vw, vh)
end

return camera
