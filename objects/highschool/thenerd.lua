local messages = {
	"I am learning C. Pointers are awesome!",
	"General protection fault? What the heck is going on?",
	"Did you know you can write an OS in C++?",
}

local playboy = {
	"Thank you! I have been searching for years for this edition.\nTake this.",
}

return {
	on_touch = function()
		if pool.sourcecode.action == "default" then
			return
		end

		local kind = pool.inventory.dragging
		if kind == "HUD/playboy" then
			state.sourcecode = true
			pool.minisourcecode.action = "default"
			pool.inventory.release()

			self.pi = (self.pi or 0) % #playboy + 1
			say(playboy[self.pi], 3, 3, 3000)
			return
		end

		self.i = (self.i or 0) % #messages + 1
		say(messages[self.i], 3, 3, 3000)
	end,
}
