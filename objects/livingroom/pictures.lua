local say = require("helpers/scribe").say

return {
  on_spawn = function()
    self._timer = timermanager:set(math.random(4, 10) * 1000, function()
      self.action = "moving"
    end)
  end,

  on_dispose = function()
    timermanager:cancel(self._timer)
  end,

  on_touch = function()
    say("What you seek, I control without help.", 3, 3, 3000)
  end,
}
