local tween = require("library/tween")
local tweens = require("helpers/tweens")
local say = require("helpers/scribe").say

return {
	on_spawn = function()
		if not state.cabinetdoor then
			return
		end
		self.action = "open"
		if not state.voodoodoll then
			pool.voodoodoll.action = "default"
		end
	end,

	on_touch = function()
		if state.cabinetdoor then
			return
		end
		self:on_touch(nil)
		state.cabinetdoor = true
		self.action = "open"
		pool.voodoodoll.action = "default"
		pool.voodoodoll.alpha = 0
		tweens.appear.voodoodoll = tween.new(1, pool.voodoodoll, { alpha = 255 })
		say("The doll is not yours, it belongs to the loa that rides it.", 3, 3, 3000)
	end,
}
