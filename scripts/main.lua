-- -- stylua: ignore
-- _G.engine = EngineFactory.new()
--   :with_title("Benchmark")
--   :with_width(3920)
--   :with_height(4080)
--   :with_scale(1.0)
--   :with_fullscreen(false)
--   :create()

-- local canvas = engine:canvas()
-- local width, height = 3920, 4080
-- -- local pixels = {}
-- local red = string.char(0xFF, 0x00, 0x00, 0xFF)
-- local pixels = red:rep(width * height)

-- function setup()
-- end

-- function loop()
--   canvas.pixels = pixels
-- end

-- stylua: ignore
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

	local stage = queryparam("stage", "mainmenu")

	scenemanager:set(stage)
end

function loop() end
