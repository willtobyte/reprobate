local scene = {}

function scene.on_enter()
  achievement:unlock("ACH_CURIUS_PERSON")
  pool.theme:play(true)
end

ticker.wrap(scene)
sentinel(scene, "whobuilt")

return scene
