local say = require("helpers/scribe").say

local messages = {
  "The road of rebellion leads to inner power.",
  "The Will to Potency.\nThe Will to Potency.\nThe Will to Potency.",
  "I have some zines, feel free to grab one.",
}

local playboy = {
  "Keep this away from me. You pevert.",
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

    if self.i == 2 then
      achievement:unlock("ACH_THE_WILL_TO_POTENCY")
    end

    if self.i == 3 then
      print(">>> TODO got zine")
    end

    say(messages[self.i], 3, 3, 3000)
  end,
}
