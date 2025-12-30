local say = require("helpers/scribe").say

return {
  on_touch = function()
    say("This game is haunted, can you feel it?")
  end,
}
