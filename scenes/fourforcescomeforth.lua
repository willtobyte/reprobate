local scene = {}

function scene.on_enter()
  state.system.stage = "fourforcescomeforth"

  transition({
    destroy = { "prelude", "mainmenu", "whobuilt", "highschool", "pearintosh" },
    register = { "chemistrylab" },
  })

  overlay.cursor:visible(false)

  pool.health:subscribe("dead", function(value)
    scenemanager:set("chemistrylab")
  end)
end

function scene.on_leave()
  overlay.cursor:visible(true)
end

function scene.on_motion(x, y)
  pool.lucifer.motion(y)
  pool.leviathan.motion(y)
  pool.belial.motion(x)
  pool.satan.motion(x)
end

sentinel(scene, "fourforcescomeforth")

return scene
