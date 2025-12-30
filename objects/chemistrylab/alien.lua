local say = require("helpers/scribe").say

local messages = {
  "I swear, officer... It was just one Space Beer!",
  "Houston, I have a hangover...",
}

return {
  on_touch = function()
    self.i = self.i % #messages + 1
    say(messages[self.i], 3, 3, 3000)
  end,
}
