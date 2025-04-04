_G.engine = EngineFactory.new()
    :with_title("Reprobate")
    :with_width(1920)
    :with_height(1080)
    :with_scale(4.0)
    :with_fullscreen(false)
    :create()

local resourcemanager = engine:resourcemanager()
local scenemanager = engine:scenemanager()
local overlay = engine:overlay()

function setup()
  resourcemanager:prefetch()

  overlay.cursor:set("horn")

  scenemanager:register("babyroom")

  scenemanager:set("babyroom")
end

function loop()
end

function run()
  engine:run()
end
