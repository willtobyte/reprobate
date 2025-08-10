local timermanager = engine:timermanager()

local M = {}

function M.appear(object)
	local duration = 500
	local interval = 32
	local steps = math.floor(duration / interval)
	local step = 0

	object.alpha = 0
	local is = object.scale
	local fs = is / 1.2

	local ia = 0
	local fa = 255

	local id
	id = timermanager:set(interval, function()
		step = step + 1

		local t = step / steps
		object.scale = is + (fs - is) * t
		object.alpha = math.floor(ia + (fa - ia) * t)

		if step >= steps then
			timermanager:clear(id)
		end
	end)
end

function M.disappear(object)
	local duration = 500
	local interval = 32
	local steps = math.floor(duration / interval)
	local step = 0

	local is = object.scale
	local fs = is * 1.2

	local ia = object.alpha
	local fa = 0

	local id
	id = timermanager:set(interval, function()
		step = step + 1

		local t = step / steps
		object.scale = is + (fs - is) * t
		object.alpha = math.floor(ia + (fa - ia) * t)

		if step >= steps then
			timermanager:clear(id)
			object:hide()
		end
	end)
end

return M
