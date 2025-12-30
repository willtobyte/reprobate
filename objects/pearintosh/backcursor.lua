return {
  on_spawn = function()
    self.action = "default"
  end,
  on_hover = function()
    self.action = "hover"
  end,
  on_unhover = function()
    self.action = "default"
  end,
  on_touch = jump.to("highschool"),
}
