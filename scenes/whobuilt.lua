local scene = {}

local scenemanager = engine:scenemanager()

local pool = {}

function scene.on_enter()
  local back = scene:get("backbutton", SceneType.object)

  back:on_hover(function(self)
    self.action:set("hover")
  end)

  back:on_unhover(function(self)
    self.action:set("default")
  end)

  back:on_touch(function(self)
    scenemanager:set("mainmenu")
  end)

  local aline = scene:get("aline", SceneType.object)

  local rodrigo = scene:get("rodrigo", SceneType.object)

  aline:on_hover(function()
    aline.action:set("hover")
  end)

  aline:on_unhover(function()
    aline.action:set("burning")
    rodrigo.action:unset()
    rodrigo.action:set("burning")
  end)

  aline:on_touch(function()
    openurl("https://linktr.ee/dandelion.pixelart")
  end)

  rodrigo:on_hover(function()
    rodrigo.action:set("hover")
  end)

  rodrigo:on_unhover(function()
    rodrigo.action:set("burning")
    aline.action:unset()
    aline.action:set("burning")
  end)

  rodrigo:on_touch(function()
    openurl("https://rodrigodelduca.org")
  end)
end

function scene.on_leave()
  pool = {}
end

return scene
