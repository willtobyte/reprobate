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
    pool.crucifix = scenemanager:grab("crucifix")
    pool.crucifix:on_touch(function()
      overlay:dispatch(Widget.cursor, "damage")
      pool.crucifix.action:unset()
    end)

    pool.gijoe = scenemanager:grab("gijoe")
    pool.gijoe:on_touch(function()
      pool.gijoe.action:unset()
    end)

    pool.nintendo = scenemanager:grab("nintendo")
    pool.nintendo:on_touch(function()
      pool.nintendo.action:unset()
    end)

    pool.playboy = scenemanager:grab("playboy")
    pool.playboy:on_touch(function()
      pool.playboy.action:unset()
    end)
  end)

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
