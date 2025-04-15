_G.engine = EngineFactory.new()
    :with_title("Reprobate")
    :with_width(1920)
    :with_height(1080)
    :with_scale(4.0)
    :with_fullscreen(true)
    :create()

local resourcemanager = engine:resourcemanager()

local scenemanager = engine:scenemanager()

local overlay = engine:overlay()

function setup()
  overlay.cursor:hide()

  resourcemanager:prefetch()

  scenemanager:register("prebabyroom")
  scenemanager:register("babyroom")

  scenemanager:set("prebabyroom")
end

function loop()
end

function run()
  engine:run()
end
