local messages = {
	"Blood Club Meeting, Tuesday 3PM",
	"Lost: Black metal vinyl. Kindly return to the main office.",
	"Spectral auditions next week!",
}

return {
	on_touch = function()
		if pool.sourcecode.action == "default" then
			return
		end

		self.i = (self.i or 0) % #messages + 1
		say(messages[self.i], 3, 3, 3000)
	end,
}
