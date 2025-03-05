---@diagnostic disable: undefined-global, undefined-field, lowercase-global
_G.engine             = EngineFactory.new()
    :with_title("Reprobate")
    :with_width(1920)
    :with_height(1080)
    :with_scale(4.0)
    :with_fullscreen(true)
    :create()

--local entitymanager   = engine:entitymanager()
local cassete         = engine:cassete()
local fontfactory     = engine:fontfactory()
local resourcemanager = engine:resourcemanager()
local scenemanager    = engine:scenemanager()
local overlay         = engine:overlay()

local label           = nil

function setup()
  resourcemanager:prefetch({ "fonts/fixedsys.json", "blobs/horn.png", "blobs/red.png" })
  scenemanager:set("1")

  -- local hammer = scenemanager:get("hammer 1")

  -- scenemanager:destroy() -- or set a new
  --

  overlay.cursor:set("horn")

  cassete:set("numbers", { 1, 2, 3 })
  local value = cassete:get("numbers")
  print("numbers: " .. table.concat(value, ", "))

  label = overlay:create(WidgetType.label)
  label.font = fontfactory:get("fixedsys")
  label:set("Hello world", 10, 10)
end

function loop()
end

function run()
  engine:run()
end
