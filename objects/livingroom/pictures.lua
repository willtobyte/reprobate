local say = require("helpers/scribe").say

return {
	on_spawn = function()
		timermanager:set(math.random(4, 10) * 1000, function()
			self.action = "moving"
		end)
	end,

	on_touch = function()
		say("What you seek, I control without help.", 3, 3, 3000)
	end,
}
