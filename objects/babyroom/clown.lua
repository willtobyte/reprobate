local say = require("helpers/scribe").say
local ticker = require("helpers/ticker")

return {
	on_spawn = function()
		ticker.every(math.random(6, 9) * 10, function()
			self.action = "blink"
		end)
	end,

	on_touch = function()
		say("A cosmic clown is closing in. Not here for laughs.")
	end,
}
