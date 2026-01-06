return {
	on_touch = function()
		if state.safe then
			return
		end

		self:on_touch(nil)

		state.safe = true

		pool.emitter1.spawning = false
		pool.emitter2.spawning = false
		pool.emitter3.spawning = false
	end,
}
