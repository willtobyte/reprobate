---@diagnostic disable: undefined-global, undefined-field, lowercase-global

--
-- Hello, magnificent curious one! Thank you for stopping by.
-- If you’d like to chat, feel free to email me at rodrigo@delduca.org.
--

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
local timemanager = TimeManager.new()

local counter = 0
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
    pool.bear = scenemanager:grab("bear")
    timemanager:set(math.random(2, 4) * 1000, function()
      pool.bear.action:set("blink")
    end)

    pool.clown = scenemanager:grab("clown")
    timemanager:set(math.random(6, 8) * 1000, function()
      pool.clown.action:set("blink")
    end)

    pool.robot = scenemanager:grab("robot")
    timemanager:set(math.random(3, 6) * 1000, function()
      pool.robot.action:set("shake")
    end)

    pool.crucifix = scenemanager:grab("crucifix")
    if cassete:get("babyroom/crucifix", false) then
      pool.crucifix:hide()
    else
      pool.crucifix:on_touch(function()
        overlay:dispatch(Widget.cursor, "damage")
        pool.crucifix:hide()
        cassete:set("babyroom/crucifix", true)
      end)
    end

    pool.gijoe = scenemanager:grab("gijoe")
    if cassete:get("babyroom/gijoe", false) then
      pool.gijoe:hide()
    else
      pool.gijoe:on_touch(function()
        pool.gijoe:hide()
        cassete:set("babyroom/gijoe", true)
      end)
    end

    pool.nintendo = scenemanager:grab("nintendo")
    if cassete:get("babyroom/nintendo", false) then
      pool.nintendo:hide()
    else
      pool.nintendo:on_touch(function()
        pool.nintendo:hide()
        cassete:set("babyroom/nintendo", true)
      end)
    end

    pool.playboy = scenemanager:grab("playboy")
    if cassete:get("babyroom/playboy", false) then
      pool.playboy:hide()
    else
      pool.playboy:on_touch(function()
        pool.playboy:hide()
        cassete:set("babyroom/playboy", true)
      end)
    end

    pool.beelzebuuth = scenemanager:grab("beelzebuuth")
  end)

  scenemanager:on_leave("babyroom", function()
    for key in pairs(pool) do
      pool[key] = nil
    end
  end)

  scenemanager:set("babyroom")
end

function loop()
  counter = counter + 1

  if counter % 666 == 0 then
    if pool.beelzebuuth then
      pool.beelzebuuth.action:set("summon")
    end
  end
end

function run()
  engine:run()
end
