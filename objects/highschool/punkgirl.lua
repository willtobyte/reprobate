local say = require("helpers/scribe").say

local messages = {
  "Reactionary discourse from state-puppet teachers.",
  "Turn off the TV, forget your idols, and face yourself.",
  "Tune in to our pirate radio station on 43.2 FM.",
}

local playboy = {
  "Take this and shove it up your ass hole.",
  "Is that your mom on the cover?",
}

return {
  on_touch = function()
    if pool.sourcecode.action == "default" then
      return
    end

    local kind = pool.inventory.dragging
    if kind == "HUD/playboy" then
      self.pi = self.pi % #playboy + 1
      say(playboy[self.pi], 3, 3, 3000)
      return
    end

    self.i = self.i % #messages + 1
    say(messages[self.i], 3, 3, 3000)
  end,
}
