local scene = {}

local pool = {}

function scene.on_enter()
	local button = scene:get("backbutton", SceneType.object)

	button:on_hover(function(self)
		print("on hover")
		local y = 1 / 0
	end)

	button:on_unhover(function(self)
		print("on unhover")
	end)
end

function scene.on_leave()
	pool = {}
end

return scene
