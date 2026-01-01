local say = require("helpers/scribe").say

return {
	on_spawn = function()
		timermanager:set(math.random(4, 10) * 1000, function()
			self.action = "blink"
		end)
	end,

	on_touch = function()
		say("Do you want to play for five nights at my house?")
	end,
}
