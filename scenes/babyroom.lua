local scene = {}

local noise = require("effects/noise")
local scribe = require("helpers/scribe")
local touch = require("helpers/touch")
local Inventory = require("overlay/inventory")

local pool = {}
local lock = false
local prefix = "babyroom/"

local cassette = engine:cassette()
local overlay = engine:overlay()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()

local postalservice = PostalService.new()

local animations = {
	car = { minimum = 3, maximum = 8, action = "run", message = "Twisted dream. Metal price" },
	bear = { minimum = 2, maximum = 4, action = "blink", message = "Do you want to play for five nights at my house?" },
	clown = {
		minimum = 6,
		maximum = 8,
		action = "blink",
		message = "A cosmic clown is closing in. Not here for laughs",
	},
	robot = { minimum = 3, maximum = 6, action = "shrug", message = "Need more input!" },
}

local items = {
	crucifix = { damage = true, hint = "His sacrifice means nothing" },
	gijoe = { damage = false, hint = "Plastic bones beneath the dust of war" },
	nintendo = { damage = false, hint = "Wires like veins, still twitching" },
	playboy = { damage = false, hint = "Paper temptations sealed behind sin" },
}

function scene.on_enter()
	noise:init()

	pool.timers = {}
	pool.collected = {}

	pool.foggy = scene:get("foggy", SceneType.effect)
	pool.television = scene:get("television", SceneType.object)
	pool.beelzebuuth = scene:get("beelzebuuth", SceneType.object)

	pool.television:on_touch(function()
		scribe:clear()
		scribe:write("This house is haunted-can you feel it?", 3, 3)
		scribe:on_finish(6000, function()
			scribe:clear()
		end)
	end)

	for name, settings in pairs(animations) do
		local object = scene:get(name, SceneType.object)

		local delay = math.random(settings.minimum, settings.maximum) * 1000

		local id = timermanager:set(delay, function()
			object.action:set(settings.action)
		end)

		object:on_touch(function()
			scribe:clear()
			scribe:write(settings.message, 3, 3)
			scribe:on_finish(6000, function()
				scribe:clear()
			end)
		end)

		pool[name] = object

		table.insert(pool.timers, id)
	end

	local objects = {}
	for name, settings in pairs(items) do
		local key = prefix .. name
		local object = scene:get(name, SceneType.object)
		pool[name] = object

		local iname = "i" .. name
		local inventory = scene:get(iname, SceneType.object)
		pool[iname] = inventory

		table.insert(objects, inventory)

		local done = cassette:get(key, false)

		pool.collected[name] = done

		if done then
			touch.disappear(object)
			inventory.action:set("default")
		end

		if not done then
			object:on_touch(function(self)
				if settings.damage then
					overlay:dispatch(WidgetType.cursor, "damage")
				end

				pool.foggy:play()
				pool.television.action:set("poltergeist")
				pool.collected[name] = true

				cassette:set(key, true)

				touch.disappear(self)
				pool[iname].action:set("default")

				for _, collected in pairs(pool.collected) do
					if not collected then
						return
					end
				end

				cassette:set("system/stage", "endgame")

				timermanager:singleshot(1000, function()
					local effect = scene:get("door", SceneType.effect)
					local door = scene:get("door", SceneType.object)
					door:on_touch(function()
						scribe:clear()
						scenemanager:set("endgame")
					end)

					door.action:set("default")

					timermanager:singleshot(3000, function()
						effect:play()
					end)
				end)
			end)
		end
	end

	local layout = scene:get("layout", SceneType.object)
	local character = scene:get("boy", SceneType.object)
	pool.inventory = Inventory.new(layout, character, objects)

	-- noise:on_finish(function()
	--   scribe:write("I drown your divinity in the Acheron of my soul", 3, 3)
	--   scribe:on_finish(12000, function() scribe:clear() end)
	-- end)
end

function scene.on_loop(delta)
	noise:loop()
	scribe:loop(delta)
	pool.inventory:loop(delta)
end

function scene.on_leave()
	noise:teardown()

	for _, id in ipairs(pool.timers) do
		timermanager:clear(id)
	end

	pool = {}
end

function scene.on_touch()
	if lock then
		return
	end

	pool.touches = (pool.touches or 0) + 1

	pool.threshold = pool.threshold or math.random(3, 6)

	if pool.touches < pool.threshold then
		return
	end

	pool.touches = 0

	pool.threshold = math.random(3, 6)

	local candidates = {}

	for name in pairs(items) do
		if not cassette:get(prefix .. name, false) then
			table.insert(candidates, name)
		end
	end

	if math.random() < 0.8 and #candidates > 0 then
		lock = true

		local chosen = candidates[math.random(#candidates)]

		scribe:clear()
		scribe:write(items[chosen].hint, 3, 3)
		scribe:on_finish(3000, function()
			scribe:clear()
			lock = false
		end)
		return
	end

	pool.beelzebuuth.action:set("summon")
	local effect = scene:get("scream", SceneType.effect)
	effect:play()

	lock = true
	timermanager:singleshot(1000, function()
		lock = false
	end)
end

function scene.on_motion(x, y)
	pool.inventory:on_motion(x, y)
end

return scene
