local scene = {}

function scene.on_enter()
	local stage = state.system.stage or "babyroom"

	transition({
		destroy = { "prelude" },
		register = { "whobuilt", stage },
	})

	pool.theme:play(true)
end

ticker.wrap(scene)
sentinel(scene, "mainmenu")

return scene
