local tween = require("library/tween")
local tweens = require("helpers/tweens")

local z = 1000

local function collectible(name, options)
	local damage = options and options.damage
	local hud = options and options.hud

	return {
		on_spawn = function()
			if not state[name] then
				return
			end

			pool[name].visible = false
			if hud then
				pool["HUD/" .. name].action = "default"
			end
		end,

		on_touch = function()
			if state[name] then
				return
			end

			local object = pool[name]
			object:on_touch(nil)
			z = z + 1
			object.z = z
			state[name] = true

			if damage then
				overlay:dispatch(WidgetType.cursor, "damage")
			end

			tweens.disappear[name] = tween.new(1, object, { alpha = 0, angle = 360, scale = 1.6 }, "inOutQuad")
			if hud then
				pool["HUD/" .. name].action = "default"
			end

			emit.collected(name)
		end,
	}
end

return collectible
