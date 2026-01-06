local messages = {
  "I swear, officer... It was just one Space Beer!",
  "Houston, I have a hangover...",
}

return {
  on_touch = function()
    if not state.safe then
      return
    end

    self.i = (self.i or 0) % #messages + 1
    say(messages[self.i], 3, 3, 3000)
  end,
}
