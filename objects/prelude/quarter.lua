return {
  on_hover = function()
    self.action = "hover"
  end,

  on_unhover = function()
    self.action = "normal"
  end,

  on_touch = jump.to("mainmenu"),
}
