_G.engine = EngineFactory.new()
    :with_title("Reprobate")
    :with_width(1920)
    :with_height(1080)
    :with_scale(4.0)
    :with_fullscreen(true)
    :create()

local cassette = engine:cassette()

local resourcemanager = engine:resourcemanager()

local scenemanager = engine:scenemanager()

local overlay = engine:overlay()

function setup()
  math.randomseed(os.time())

  resourcemanager:prefetch()

  overlay.cursor:set("horn")

  scenemanager:register("mainmenu")
  scenemanager:register("babyroom")

  scenemanager:set("mainmenu")
end

function loop()
end

function run()
  engine:run()
end
