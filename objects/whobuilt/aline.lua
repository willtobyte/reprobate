return {
  on_hover = function()
    self.action = "hover"
  end,
  on_unhover = function()
    self.action = "burning"
    pool.rodrigo.action = nil
    pool.rodrigo.action = "burning"
  end,
  on_touch = function()
    openurl("https://linktr.ee/dandelion.pixelart")
  end,
}
