local scene = {}

local overlay = engine:overlay()

local scenemanager = engine:scenemanager()

local scribe = require("helpers/scribe")

local pool = {}

function scene.on_enter()
  pool.ready = false

  scribe.write([[
198666: Spawned a goddamn bastard
Anarchist to the core
Satanic to the bone
  ]], 3, 3)

  function callback()
    pool.ready = true
    scribe.clear()
    overlay.cursor:set("horn")
  end

  scribe.on_finish(1000, callback)
end

function scene.on_touch()
  if pool.ready then
    scenemanager:set("babyroom")
  end
end

return scene
