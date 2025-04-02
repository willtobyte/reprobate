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
-- local canvas = engine:canvas()

function setup()
  resourcemanager:prefetch({
    "blobs/babyroom.png",
    "blobs/bear.png",
    "blobs/beelzebuuth.png",
    "blobs/clown.png",
    "blobs/crucifix.png",
    "blobs/door.ogg",
    "fonts/fixedsys.json",
    "blobs/gijoe.png",
    "blobs/gore.ogg",
    "blobs/horn.png",
    "blobs/metal.ogg",
    "blobs/nintendo.png",
    "blobs/playboy.png",
    "blobs/robot.png",
    "blobs/scream.ogg",
    "blobs/wind.ogg",
  })

  overlay.cursor:set("horn")

  scenemanager:register("babyroom")

  scenemanager:set("babyroom")
end

function loop()
end

function run()
  engine:run()
end
