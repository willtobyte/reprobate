return {
  on_spawn = function()
    self._timer = timermanager:singleshot(6666, function()
      self.action = "default"
    end)
  end,

  on_dispose = function()
    timermanager:cancel(self._timer)
  end,
}
