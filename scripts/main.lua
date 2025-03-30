---@diagnostic disable: undefined-global, undefined-field, lowercase-global

--
-- Hello, magnificent curious one! Thank you for stopping by.
-- If you’d like to chat, feel free to email me at rodrigo@delduca.org.
--

local babyroom = require("scenes/babyroom")

_G.engine = EngineFactory.new()
    :with_title("Reprobate")
    :with_width(1920)
    :with_height(1080)
    :with_scale(4.0)
    :with_fullscreen(false)
    :create()

local cassete = engine:cassete()
local resourcemanager = engine:resourcemanager()
local scenemanager = engine:scenemanager()
local overlay = engine:overlay()

local pool = {}

function setup()
  resourcemanager:prefetch({
    "blobs/babyroom.png",
    "blobs/bear.png",
    "blobs/beelzebuuth.png",
    "blobs/clown.png",
    "blobs/crucifix.png",
    "fonts/fixedsys.json",
    "blobs/gijoe.png",
    "blobs/horn.png",
    "blobs/nintendo.png",
    "blobs/playboy.png",
    "blobs/robot.png",
  })

  overlay.cursor:set("horn")

  scenemanager:on_enter("babyroom", function()
    babyroom.on_enter(scenemanager, cassete)
  end)

  scenemanager:on_loop("babyroom", function(delta)
    babyroom.on_loop(delta)
  end)

  scenemanager:on_leave("babyroom", function()
    babyroom.on_leave(scenemanager, cassete)
  end)

  scenemanager:set("babyroom")
end

function loop()
end

function run()
  engine:run()
end
