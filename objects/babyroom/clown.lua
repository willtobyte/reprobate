return {
  on_spawn = function()
    ticker.every(math.random(13, 16) * 10, function()
      self.action = "blink"
    end)
  end,

  on_touch = function()
    say("A cosmic clown is closing in. Not here for laughs.")
  end,
}
