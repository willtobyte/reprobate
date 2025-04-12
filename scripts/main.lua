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
local fontfactory = engine:fontfactory()
local overlay = engine:overlay()

local label = nil

function setup()
  label = overlay:create(WidgetType.label)
  label.font = fontfactory:get("verminvibes")
  label:set("Rodrigo Delduca! 666", 0, 0)

  resourcemanager:prefetch()

  overlay.cursor:set("horn")

  scenemanager:register("babyroom")

  scenemanager:set("babyroom")
end

function loop()
end

function run()
  engine:run()
end
