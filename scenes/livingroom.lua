local scene = {}

local pool = {}

local timermanager = engine:timermanager()

local animations = {
	window = { minimum = 4, maximum = 8, action = "lightning", message = "TODO..." },
}

function scene.on_enter()
	pool.timers = {}

	for name, settings in pairs(animations) do
		local object = scene:get(name, SceneType.object)

		local delay = math.random(settings.minimum, settings.maximum) * 1000

		local id = timermanager:set(delay, function()
			object.action = settings.action
		end)

		table.insert(pool.timers, id)

		pool[name] = object
	end
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
