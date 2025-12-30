local say = require("helpers/scribe").say

local messages = {
  "If all this fades into gray and absence?",
  "Want to study together after school?",
  "I heard there is a secret room behind the library.",
}

local playboy = {
  "Let me guess, you thought this was romantic?",
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
