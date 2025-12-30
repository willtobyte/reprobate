local say = require("helpers/scribe").say

return {
  on_spawn = function()
    self._timer = timermanager:set(math.random(3, 8) * 1000, function()
      self.action = "shrug"
    end)
  end,

  on_dispose = function()
    timermanager:cancel(self._timer)
  end,

  on_touch = function()
    say("Need more input!")
  end,
}
