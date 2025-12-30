local say = require("helpers/scribe").say

local messages = {
  "Have you finished your homework yet?",
  "People say the cafeteria ground beef is human.",
}

local playboy = {
  "The pages are all stuck together. Modern art, probably.",
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
