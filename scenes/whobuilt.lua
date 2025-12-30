local scene = {}

function scene.on_enter()
  achievement:unlock("ACH_CURIUS_PERSON")
  pool.theme:play(true)
end

sentinel(scene, "whobuilt")

return scene
