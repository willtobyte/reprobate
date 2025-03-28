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
    :with_fullscreen(false)
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
    "blobs/blue.png",
    "fonts/fixedsys.json",
    "blobs/horn.png",
    "blobs/player.png",
    "blobs/red.png"
  })

  overlay.cursor:set("horn")

  scenemanager:on_enter("0", function()
    pool.label = overlay:create(WidgetType.label)
    pool.label.font = fontfactory:get("fixedsys")
    pool.label:set("Ok", 10, 10)

    pool.button = scenemanager:grab("button")
    pool.button:on_touch(function()
      scenemanager:set("1")
    end)
  end)

  scenemanager:on_leave("0", function()
    overlay:destroy(pool.label)

    for key in pairs(pool) do
      pool[key] = nil
    end
  end)

  scenemanager:on_enter("1", function()
    pool.label = overlay:create(WidgetType.label)
    pool.label.font = fontfactory:get("fixedsys")
    pool.label:set("Run", 40, 40)

    pool.player = scenemanager:grab("player")
    pool.player:on_touch(function()
      overlay:dispatch(WidgetType.cursor, "damage")
      scenemanager:set("0")
    end)

    pool.player:on_ntick(10, function()
      print("on tick")
    end)
  end)

  scenemanager:on_leave("1", function()
    overlay:destroy(pool.label)

    for key in pairs(pool) do
      pool[key] = nil
    end
  end)

  scenemanager:set("0")
end

function loop(delta)
  local w, h, bs = 480, 270, 4
  local green, transparent = 0xFF00FF00, 0x00000000
  local total = w * h
  local pixels = {}

  for i = 1, total do
    pixels[i] = green
  end

  for y = bs, h - bs - 1 do
    local base = y * w
    for x = bs, w - bs - 1 do
      pixels[base + x + 1] = transparent
    end
  end

  canvas.pixels = pixels
end

function run()
  engine:run()
end
