return {
	on_spawn = function()
		if state.bottomcabinetdoor then
			self.action = "open"
		end
	end,

	on_touch = function()
		if state.bottomcabinetdoor then
			return
		end
		self:on_touch(nil)
		state.bottomcabinetdoor = true
		self.action = "open"
		pool.tubeamplifier.action = "default"
		pool.tubeamplifier.alpha = 0
		tweens.appear.tubeamplifier = tween.new(1, pool.tubeamplifier, { alpha = 255 })
	end,
}
