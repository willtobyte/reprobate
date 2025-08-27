local scene = {}

local scenemanager = engine:scenemanager()

local pool = {}

function scene.on_enter()
  local music = scene:get("theme", SceneType.effect)
  music:play(true)

  pool.symbols = scene:get("symbols", SceneType.object)
  pool.goat = scene:get("goat", SceneType.effect)
  pool.symbols:on_touch(function()
    pool.goat:play()
  end)

  pool.back = scene:get("backbutton", SceneType.object)

  pool.back:on_hover(function(self)
    self.action = "hover"
  end)

  pool.back:on_unhover(function(self)
    self.action = "default"
  end)

  pool.back:on_touch(function()
    scenemanager:set("mainmenu")
  end)

  pool.aline = scene:get("aline", SceneType.object)

  pool.rodrigo = scene:get("rodrigo", SceneType.object)

  pool.aline:on_hover(function(self)
    self.action = "hover"
  end)

  pool.aline:on_unhover(function(self)
    self.action = "burning"
    pool.rodrigo.action = nil
    pool.rodrigo.action = "burning"
  end)

  pool.aline:on_touch(function()
    openurl("https://linktr.ee/dandelion.pixelart")
  end)

  pool.rodrigo:on_hover(function(self)
    self.action = "hover"
  end)

  pool.rodrigo:on_unhover(function(self)
    self.action = "burning"
    pool.aline.action = nil
    pool.aline.action = "burning"
  end)

  pool.rodrigo:on_touch(function()
    openurl("https://rodrigodelduca.org")
  end)
end

function scene.on_leave()
  for o in pairs(pool) do
    pool[o] = nil
  end
end

return scene
