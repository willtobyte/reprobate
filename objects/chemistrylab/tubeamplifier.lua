local base = collectible("tubeamplifier")
local original = base.on_touch

base.on_touch = function()
	if not state.safe then
		return
	end
	original()
end

return base
