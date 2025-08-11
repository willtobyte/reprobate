local scene = {}

local scribe = require("helpers/scribe")
local lightning = require("effects/lightning")
local visibility = require("helpers/visibility")

local pool = {}
local lock = false
local prefix = "livingroom/"

local cassette = engine:cassette()

local timermanager = engine:timermanager()

local animations = {
	antiquewallclock = {
		message = "The sands of time for me are running low...",
	},
	baphomet = {
		message = "Hell? The worst torment is to live in this realm of hypocrisy.",
	},
	bloodpriest = {
		message = "...Cast into the fields of evil pleasure.",
	},
	pictures = {
		minimum = 3,
		maximum = 6,
		action = "moving",
		message = "What you seek, I control without help.",
	},
	mirrors = {
		message = "Banished, cold, alone, through the mirror I watch, aeons away.",
	},
	ogremask = {
		message = "Oni no tsume de omae no tamashii o hikisake.",
	},
	window = {
		minimum = 8,
		maximum = 16,
		action = "lightning",
		message = "You cannot escape your own mind.",
		lightning = true,
	},
}

function scene.on_enter()
	pool.timers = {}

	for name, settings in pairs(animations) do
		local object = scene:get(name, SceneType.object)

		local timed = settings.minimum and settings.maximum or false

		if timed then
			local delay = math.random(settings.minimum, settings.maximum) * 1000

			local id = timermanager:set(delay, function()
				object.action = settings.action

				if settings.lightning then
					lightning:trigger()

					local thunder = scene:get("thunder", SceneType.effect)
					thunder:play()

					pool.thundered = true -- TODO if false, before final animation the game triggers lightning + thunder.
				end
			end)

			table.insert(pool.timers, id)
		end

		object:on_touch(function()
			if lock then
				return
			end

			lock = true
			scribe:clear()
			scribe:write(settings.message, 3, 3)
			scribe:on_finish(3000, function()
				scribe:clear()
				lock = false
			end)
		end)

		pool[name] = object
	end

	pool.cabinetdoor = scene:get("cabinetdoor", SceneType.object)
	pool.voodoodoll = scene:get("voodoodoll", SceneType.object)
	pool.cabinetdoor:on_touch(function()
		pool.cabinetdoor.action = "open"
		pool.voodoodoll.action = "default"

		visibility.appear(pool.voodoodoll)

		local warning = "The doll is not yours, it belongs to the loa that rides it."
		scribe:clear()
		scribe:write(warning, 3, 3)
		scribe:on_finish(3000, function()
			scribe:clear()
		end)
	end)
end

function scene.on_motion(x, y)
	-- effect:motion(x, y)
end

function scene.on_loop(delta)
	lightning:loop()
	scribe:loop(delta)
	-- pool.inventory:loop(delta)
end

function scene.on_leave()
	for _, id in ipairs(pool.timers) do
		timermanager:clear(id)
	end

	for o in pairs(pool) do
		pool[o] = nil
	end
end

return scene
