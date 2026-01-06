return {
  on_spawn = function()
    ticker.every(math.random(4, 10) * 10, function()
      self.action = "moving"
    end)
  end,

  on_touch = function()
    say("What you seek, I control without help.", 3, 3, 3000)
  end,
}
