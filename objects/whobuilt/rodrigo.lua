return {
  on_hover = function()
    self.action = "hover"
  end,
  on_unhover = function()
    self.action = "burning"
    pool.aline.action = nil
    pool.aline.action = "burning"
  end,
  on_touch = function()
    openurl("https://rodrigodelduca.org")
  end,
}
