local scene = {}

local tween = require("library/tween")
local tweens = require("helpers/tweens")
local scribe = require("helpers/scribe")

local Inventory = require("overlay/inventory")

local hideable = {
	"antiquewallclock",
	"baphomet",
	"bloodpriest",
	"pictures",
	"mirrors",
	"ogremask",
	"window",
}

local items = { "sugarcanespirit", "voodoodoll" }

local function verify()
	for _, name in ipairs(items) do
		if not state[name] then
			return
		end
	end

	state.system.stage = "highschool"
	pool.gettingintometal:play()

	timermanager:singleshot(2000, function()
		scribe.clear()

		for _, name in ipairs(hideable) do
			if pool[name] then
				pool[name].visible = false
			end
		end

		pool.cabinetdoor.visible = false
		pool.teenager.action = "default"
		pool.teenager.alpha = 200
		tweens.appear.teenager = tween.new(3, pool.teenager, { alpha = 255 })
	end)

	timermanager:singleshot(5000, function()
		pool.teenager.action = nil
		pool.teenager.action = "default"
		pool.voodoocast.action = "default"
		pool.voodoocast.alpha = 0
		tweens.appear.voodoocast = tween.new(3, pool.voodoocast, { alpha = 255 })
	end)

	timermanager:singleshot(9000, function()
		pool.teenager:on_touch(jump.to("highschool"))
	end)
end

local collected = nil

function scene.on_enter()
	state.system.stage = "livingroom"

	transition({
		destroy = { "mainmenu", "whobuilt", "babyroom" },
		register = { "highschool" },
	})

	collected = slot.collected(verify)

	local objects = {}
	-- for _, name in ipairs(items) do
	--  table.insert(objects, pool["HUD/" .. name])
	-- end

	pool.inventory = Inventory.new(pool.layout, pool.boy, objects)

	pool.rainmuffled:play(true)
end

function scene.on_motion(x, y)
	pool.inventory.motion(x, y)
end

function scene.on_loop(delta)
	scribe.loop(delta)

	pool.inventory.loop(delta)

	tweens.loop(delta, function(type, name, t)
		if t.subject and type == "disappear" then
			t.subject.visible = false
		end
	end)
end

function scene.on_leave()
	disconnect(collected)
	scribe.clear()
	tweens.teardown()
end

sentinel(scene, "livingroom")

return scene
