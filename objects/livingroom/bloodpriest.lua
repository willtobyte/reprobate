local say = require("helpers/scribe").say

local messages = {
  "...Cast into the fields of evil pleasure.",
  "Hear they dead lips...",
}

return {
  on_touch = function()
    self.i = (self.i or 0) % #messages + 1
    say(messages[self.i], 3, 3, 3000)
  end,
}
