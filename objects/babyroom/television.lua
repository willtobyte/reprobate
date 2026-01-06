return {
  on_touch = function()
    say("This game is haunted, can you feel it?")
  end,

  on_animate = function()
    self.action = "poltergeist"
  end,
}
