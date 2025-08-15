local scene = {}

local pool = {}

function scene.on_enter()
	pool.clock = scene:get("click", SceneType.effect)
end

function scene.on_touch(x, y)
	pool.clock:play()
end

function scene.on_loop() end

function scene.on_leave()
	for o in pairs(pool) do
		pool[o] = nil
	end
end

return scene
