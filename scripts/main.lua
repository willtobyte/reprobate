-- -- stylua: ignore
-- _G.engine = EngineFactory.new()
--   :with_title("Tela Vermelha")
--   :with_width(1920)
--   :with_height(1080)
--   :with_scale(1.0)
--   :with_fullscreen(false)
--   :create()

-- local canvas = engine:canvas()
-- local width, height = 1920, 1080
-- local pixels = {}

-- function setup()
--   local red = 0xFF0000FF
--   for i = 1, width * height do
--     pixels[i] = red
--   end
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
  :with_fullscreen(false)
  :create()

local scenemanager = engine:scenemanager()

local overlay = engine:overlay()

function setup()
	overlay.cursor:set("horn")

	scenemanager:register("mainmenu")
	scenemanager:register("whobuilt")
	scenemanager:register("babyroom")
	scenemanager:register("pearintosh")

	local stage = queryparam("stage", "mainmenu")

	scenemanager:set(stage)
end

function loop() end
