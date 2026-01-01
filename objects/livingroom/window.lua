local say = require("helpers/scribe").say

local lightning = { active = false, next_at = 0, count = 0, total = 0, phase = nil }

local function trigger()
	if lightning.active then
		return
	end
	lightning.active = true
	lightning.count = 0
	lightning.total = math.random(3, 4)
	lightning.phase = "bright"
	pool.darker.action = nil
	lightning.next_at = moment() + math.random(20, 30)
end

return {
	on_spawn = function()
		timermanager:set(math.random(3, 6) * 1000, function()
			self.action = "lightning"
			trigger()
			pool.thunder:play()
		end)
	end,

	on_loop = function()
		if not lightning.active then
			return
		end

		local now = moment()
		if now < lightning.next_at then
			return
		end

		if lightning.phase == "bright" then
			lightning.count = lightning.count + 1
			pool.darker.action = "default"
			if lightning.count >= lightning.total then
				lightning.active = false
				lightning.phase = nil
				return
			end
			lightning.phase = "dark"
			lightning.next_at = now + math.random(20, 30)
			return
		end

		pool.darker.action = nil
		lightning.phase = "bright"
		lightning.next_at = now + math.random(20, 30)
	end,

	on_touch = function()
		say("You cannot escape your own mind.", 3, 3, 3000)
	end,
}
