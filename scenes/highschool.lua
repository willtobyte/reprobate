local scene = {}

function scene.on_enter()
  state.system.stage = "highschool"

  transition({
    destroy = { "prelude", "mainmenu", "whobuilt", "livingroom" },
    register = { "pearintosh", "fourforcescomeforth" },
  })

  if not state.sourcecode then
    return
  end

  pool.minisourcecode.action = "default"
  pool["HUD/playboy"].action = nil
end

function scene.on_loop(delta)
  scribe.loop(delta)
  tweens.loop(delta)
end

function scene.on_leave()
  scribe.clear()
  tweens.teardown()
end

HUD(scene, {
  layout = "layout",
  character = "boy",
  items = { "playboy" },
})

ticker.wrap(scene)
sentinel(scene, "highschool")

return scene
