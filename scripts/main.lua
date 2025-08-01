_G.engine = EngineFactory.new()
	:with_title("Reprobate")
	:with_width(1920)
	:with_height(1080)
	:with_scale(4.0)
	:with_fullscreen(true)
	:create()

local scenemanager = engine:scenemanager()

local overlay = engine:overlay()

function setup()
	overlay.cursor:set("horn")

	scenemanager:register("mainmenu")
	scenemanager:register("whobuilt")
	scenemanager:register("babyroom")
	scenemanager:register("pearintosh")
	scenemanager:register("thankyou")
	scenemanager:register("pixelslabs")

	local stage = queryparam("stage", "mainmenu")

	-- stage = "pixelslabs"
	scenemanager:set(stage)
end

function loop() end
