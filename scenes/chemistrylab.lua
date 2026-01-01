local scene = {}

local tweens = require("helpers/tweens")
local scribe = require("helpers/scribe")

local items = { "openendwrench", "smallkey", "gasoline", "tubeamplifier" }

local function verify()
	for _, name in ipairs(items) do
		if not state[name] then
			return
		end
	end
	-- TODO
end

local held = nil

function scene.on_enter()
	state.system.stage = "chemistrylab"

	held = slot.held(verify)

	pool.geigereffect:play(true)

	if state.fireextinguished then
		for i = 1, 3 do
			pool["emitter" .. i].spawning = false
		end
	end
end

function scene.on_motion(x, y)
	local alien_x, alien_y, alien_w, alien_h = 249, 183, 127, 48
	local cx = alien_x + alien_w * 0.5
	local cy = alien_y + alien_h * 0.5

	local dx, dy = x - cx, y - cy
	local distance = math.sqrt(dx * dx + dy * dy)

	local r_max = math.min(cx, 480 - cx, cy, 270 - cy)
	if r_max <= 0 then
		return
	end

	local t = math.min(distance / r_max, 1.0)
	local volume = 1.0 - 0.9 * t

	pool.geigereffect.volume = volume
end

function scene.on_loop(delta)
	scribe.loop(delta)

	if not pool.alien.visible then
		pool.geigereffect:stop()
	end

	tweens.loop(delta, function(type, name, t)
		if t.subject and type == "disappear" then
			t.subject.visible = false
		end
	end)
end

function scene.on_leave()
	disconnect(held)
	scribe.clear()
	tweens.teardown()
end

sentinel(scene, "chemistrylab")

return scene
