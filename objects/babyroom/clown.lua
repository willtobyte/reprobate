local say = require("helpers/scribe").say

return {
	on_spawn = function()
		timermanager:set(math.random(6, 9) * 1000, function()
			self.action = "blink"
		end)
	end,

	on_touch = function()
		say("A cosmic clown is closing in. Not here for laughs.")
	end,
}
