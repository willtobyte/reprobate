local say = require("helpers/scribe").say

local messages = {
  "Dawn no longer comes.",
  "Time catches up with everyone;\nSooner or later, the moment will come.",
}

return {
  on_touch = function()
    self.i = (self.i or 0) % #messages + 1
    say(messages[self.i], 3, 3, 3000)
  end,
}
