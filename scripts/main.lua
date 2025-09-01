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

  scenemanager:register("babyroom")
  scenemanager:register("livingroom")
  scenemanager:register("mainmenu")
  scenemanager:register("pearintosh")
  scenemanager:register("prelude")
  scenemanager:register("whobuilt")

  scenemanager:register("pixelslabs")

  local stage = queryparam("stage", "prelude")

  scenemanager:set(stage)

  local file = io.open(desktop:path() .. "test.txt", "w")
  file:write("Hello World")
  file:close()
end

function loop() end
