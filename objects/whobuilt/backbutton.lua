return {
  on_hover = function()
    self.action = "hover"
  end,
  on_unhover = function()
    self.action = "default"
  end,
  on_touch = jump.to("mainmenu"),
}
