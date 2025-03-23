---@diagnostic disable: undefined-global, undefined-field, lowercase-global
_G.engine             = EngineFactory.new()
    :with_title("Reprobate")
    :with_width(1920)
    :with_height(1080)
    :with_scale(4.0)
    :with_fullscreen(true)
    :create()

local entitymanager   = engine:entitymanager()
-- local cassete         = engine:cassete()
local fontfactory     = engine:fontfactory()
local resourcemanager = engine:resourcemanager()
local scenemanager    = engine:scenemanager()
local overlay         = engine:overlay()

local io              = Socket.new()

local label           = nil
local lettercoro      = nil

function setup()
  resourcemanager:prefetch({ "fonts/fixedsys.json", "blobs/horn.png", "blobs/player.png", "blobs/red.png" })

  overlay.cursor:set("horn")

  label = overlay:create(WidgetType.label)
  label.font = fontfactory:get("fixedsys")
  label:set("Hello world", 10, 10)

  scenemanager:set("1")

  local player = scenemanager:grab("player")
  player:on_touch(function()
    overlay:dispatch(WidgetType.cursor, "damage")
  end)

  -- player = nil
  -- scenemanager:set("2")
  --
  io:on("online", function(data)
    print("Online " .. data.clients)
  end)

  io:connect()

  lettercoro = coroutine.create(function()
    local text = "Hello world"
    local result = ""
    for i = 1, #text do
      result = result .. text:sub(i, i)
      label:set(result, 10, 10)

      local timer = 0
      while timer < 0.1 do
        local dt = coroutine.yield()
        timer = timer + dt
      end
    end
  end)
end

function loop(delta)
  if lettercoro and coroutine.status(lettercoro) ~= "dead" then
    coroutine.resume(lettercoro, delta)
  end
end

function run()
  engine:run()
end
