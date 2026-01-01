local say = require("helpers/scribe").say
local ticker = require("helpers/ticker")

return {
	on_spawn = function()
		ticker.every(math.random(4, 10) * 10, function()
			self.action = "blink"
		end)
	end,

	on_touch = function()
		say("Do you want to play for five nights at my house?")
	end,
}
