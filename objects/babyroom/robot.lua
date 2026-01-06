return {
  on_spawn = function()
    ticker.every(math.random(3, 8) * 10, function()
      self.action = "shrug"
    end)
  end,

  on_touch = function()
    say("Need more input!")
  end,
}
