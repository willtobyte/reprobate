local scene = {}

function scene.on_enter()
	local stage = state.system.stage or "babyroom"

	transition({
		destroy = { "prelude" },
		register = { "whobuilt", stage },
	})

	pool.theme:play(true)
end

function scene.on_motion(x)
	pool.headbanger.motion(x)
end

ticker.wrap(scene)
sentinel(scene, "mainmenu")

return scene
