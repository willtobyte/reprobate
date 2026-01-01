return {
	on_spawn = function()
		ticker.after(66, function()
			self.action = "default"
		end)
	end,
}
