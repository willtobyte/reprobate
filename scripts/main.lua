---@diagnostic disable: undefined-global, undefined-field, lowercase-global

--
-- Hello, magnificent curious one! Thank you for stopping by.
-- If you’d like to chat, feel free to email me at rodrigo@delduca.org.
--

_G.engine             = EngineFactory.new()
    :with_title("Reprobate")
    :with_width(1920)
    :with_height(1080)
    :with_scale(4.0)
    :with_fullscreen(true)
    :create()

local entitymanager   = engine:entitymanager()
local fontfactory     = engine:fontfactory()
local resourcemanager = engine:resourcemanager()
local scenemanager    = engine:scenemanager()
local overlay         = engine:overlay()
local canvas          = engine:canvas()

local pool            = {}

function setup()
  resourcemanager:prefetch({
    "blobs/babyroom.png",
    "blobs/bear.png",
    "blobs/beelzebuuth.png",
    "blobs/clown.png",
    "fonts/fixedsys.json",
    "blobs/horn.png",
    "blobs/robot.png",
  })

  overlay.cursor:set("horn")

  scenemanager:on_leave("babyroom", function()
    for key in pairs(pool) do
      pool[key] = nil
    end
  end)

  scenemanager:set("babyroom")
end

function loop(delta)
end

function run()
  engine:run()
end
