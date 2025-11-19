local scene = {}

function scene.on_enter()
  local stage = state.system.stage or "babyroom"

  transition({
    destroy = { "prelude", "mainmenu", "whobuilt" },
    register = { "whobuilt", stage },
  })

  pool.noise = scene:get("noise", SceneType.effect)
  pool.noise:play(true)

  pool.interference = scene:get("interference", SceneType.object)
  pool.interference:on_end(function()
    scenemanager:set(stage)
  end)
end

sentinel(scene, "retrostatic")

return scene
