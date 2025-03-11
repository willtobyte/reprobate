---@diagnostic disable: undefined-global, undefined-field, lowercase-global
_G.engine             = EngineFactory.new()
    :with_title("Reprobate")
    :with_width(1920)
    :with_height(1080)
    :with_scale(4.0)
    :with_fullscreen(false)
    :create()

local entitymanager   = engine:entitymanager()
-- local cassete         = engine:cassete()
local fontfactory     = engine:fontfactory()
local resourcemanager = engine:resourcemanager()
local scenemanager    = engine:scenemanager()
local overlay         = engine:overlay()

local scene           = nil
local label           = nil

function setup()
  resourcemanager:prefetch({ "blobs/fixedsys.png", "blobs/horn.png" })

  overlay.cursor:set("horn")

  label = overlay:create(WidgetType.label)
  label.font = fontfactory:get("fixedsys")
  label:set("Hello world", 10, 10)

  scene = require("scenes/1").construct(scenemanager, entitymanager)
end

function loop(delta)
  if scene then
    scene:loop(delta)
  end
end

function run()
  engine:run()
end
