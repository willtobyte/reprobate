local say = require("helpers/scribe").say

return {
	on_spawn = function()
		timermanager:set(math.random(5, 8) * 1000, function()
			self.action = "run"
		end)
	end,

	on_touch = function()
		say("Twisted dream. Metal price.")
	end,
}
