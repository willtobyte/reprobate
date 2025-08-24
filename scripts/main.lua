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

  local stage = "prelude"

  scenemanager:register("babyroom")
  scenemanager:register("livingroom")
  scenemanager:register("mainmenu")
  scenemanager:register("whobuilt")
  scenemanager:register("babyroom")
  scenemanager:register("prelude")

  scenemanager:register(stage)
  scenemanager:set(stage)
end

function loop() end
