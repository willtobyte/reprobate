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

  local stage = queryparam("stage", "mainmenu")

  scenemanager:set(stage)
end

function loop() end
