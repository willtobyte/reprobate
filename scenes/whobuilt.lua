local scene = {}

function scene.on_enter()
  achievement:unlock("ACH_CURIUS_PERSON")

  pool.theme:play(true)

  pool.symbols:on_touch(function()
    achievement:unlock("ACH_BLESSED_BY_THE_GOAT")
    pool.goat:play()
  end)

  pool.backbutton:on_hover(function(self)
    self.action = "hover"
  end)

  pool.backbutton:on_unhover(function(self)
    self.action = "default"
  end)

  pool.backbutton:on_touch(jump.to("mainmenu"))

  pool.aline:on_hover(function(self)
    self.action = "hover"
  end)

  pool.aline:on_unhover(function()
    pool.aline.action = "burning"
    pool.rodrigo.action = nil
    pool.rodrigo.action = "burning"
  end)

  pool.aline:on_touch(function()
    openurl("https://linktr.ee/dandelion.pixelart")
  end)

  pool.rodrigo:on_hover(function(self)
    self.action = "hover"
  end)

  pool.rodrigo:on_unhover(function()
    pool.rodrigo.action = "burning"
    pool.aline.action = nil
    pool.aline.action = "burning"
  end)

  pool.rodrigo:on_touch(function()
    openurl("https://rodrigodelduca.org")
  end)
end

sentinel(scene, "whobuilt")

return scene
