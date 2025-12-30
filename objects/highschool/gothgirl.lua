local say = require("helpers/scribe").say

local messages = {
  "I will not speak of stars, for the universe has faded away.",
  "Shattered embers of ancient stars, wandering in flesh.",
  "Darkness is not the absence of light, it is the abyss itself.",
}

local playboy = {
  "How adorable. You mistook me for someone alive inside.",
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
