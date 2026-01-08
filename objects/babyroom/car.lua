return {
  on_spawn = function()
    ticker.every(math.random(6, 8) * 10, function()
      self.action = "run"
    end)
  end,

  on_touch = function()
    say("Twisted dream. Metal price.")
  end,
}
