return {
  on_motion = function(x)
    if x > 240 then
      self.action = "right"
    else
      self.action = "left"
    end
  end,
}
