local scene = {}

local scenemanager = engine:scenemanager()

local pool = {}

function scene.on_enter()
  local music = scene:get("theme", SceneType.effect)
  music:play(true)

  local back = scene:get("backbutton", SceneType.object)

  back:on_hover(function()
    back.action = "hover"
  end)

  back:on_unhover(function()
    back.action = "default"
  end)

  back:on_touch(function()
    scenemanager:set("mainmenu")
  end)

  local aline = scene:get("aline", SceneType.object)

  local rodrigo = scene:get("rodrigo", SceneType.object)

  aline:on_hover(function()
    aline.action = "hover"
  end)

  aline:on_unhover(function()
    aline.action = "burning"
    rodrigo.action = nil
    rodrigo.action = "burning"
  end)

  aline:on_touch(function()
    openurl("https://linktr.ee/dandelion.pixelart")
  end)

  rodrigo:on_hover(function()
    rodrigo.action = "hover"
  end)

  rodrigo:on_unhover(function()
    rodrigo.action = "burning"
    aline.action = nil
    aline.action = "burning"
  end)

  rodrigo:on_touch(function()
    openurl("https://rodrigodelduca.org")
  end)
end

function scene.on_leave()
  pool = {}
end

return scene
