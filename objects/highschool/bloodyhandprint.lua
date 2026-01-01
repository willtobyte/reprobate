return {
	on_spawn = function()
		timermanager:singleshot(6666, function()
			self.action = "default"
		end)
	end,
}
