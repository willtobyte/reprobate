local ticker = {}
local counters = {}
local id = 0

function ticker.after(ticks, callback)
	id = id + 1
	counters[id] = { target = ticks, current = 0, callback = callback, once = true }
	return id
end

function ticker.every(ticks, callback)
	id = id + 1
	counters[id] = { target = ticks, current = math.random(0, ticks - 1), callback = callback, once = false }
	return id
end

function ticker.cancel(timer_id)
	counters[timer_id] = nil
end

function ticker.clear()
	counters = {}
end

function ticker.tick()
	local to_remove = {}
	for tid, c in pairs(counters) do
		c.current = c.current + 1
		if c.current >= c.target then
			c.callback()
			if c.once then
				to_remove[#to_remove + 1] = tid
			else
				c.current = 0
			end
		end
	end
	for i = 1, #to_remove do
		counters[to_remove[i]] = nil
	end
end

function ticker.wrap(scene)
	local original_on_tick = scene.on_tick
	local original_on_leave = scene.on_leave

	scene.on_tick = function(tick)
		ticker.tick()
		if original_on_tick then
			original_on_tick(tick)
		end
	end

	scene.on_leave = function()
		if original_on_leave then
			original_on_leave()
		end
		ticker.clear()
	end

	return scene
end

return ticker
