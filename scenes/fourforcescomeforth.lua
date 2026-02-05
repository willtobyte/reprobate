local scene = {}

function scene.on_enter()
  pool.health:subscribe("dead", function(value)
    print("dead changed to", value)
  end)
end

function scene.on_motion(x, y)
  pool.lucifer.motion(y)
  pool.leviathan.motion(y)
  pool.belial.motion(x)
  pool.satan.motion(x)
end

sentinel(scene, "fourforcescomeforth")

return scene
