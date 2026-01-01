local say = require("helpers/scribe").say
local ticker = require("helpers/ticker")

return {
	on_spawn = function()
		ticker.every(math.random(5, 8) * 10, function()
			self.action = "run"
		end)
	end,

	on_touch = function()
		say("Twisted dream. Metal price.")
	end,
}
