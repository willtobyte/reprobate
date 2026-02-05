local scene = {}

function scene.on_enter()
  pool.blood:subscribe("dead", function(value)
    print("dead changed to", value)
  end)
end

function scene.on_motion(x, y)
  --
end

function scene.on_touch()
  pool.blood.damage()
end

sentinel(scene, "fourforcescomeforth")

return scene
