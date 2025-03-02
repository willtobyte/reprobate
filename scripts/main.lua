---@diagnostic disable: undefined-global, undefined-field, lowercase-global
_G.engine             = EngineFactory.new()
    :with_title("Reprobate")
    :with_width(1920)
    :with_height(1080)
    :with_scale(4.0)
    :with_fullscreen(true)
    :create()

local entitymanager   = engine:entitymanager()
local resourcemanager = engine:resourcemanager()
local scenemanager    = engine:scenemanager()

function setup()
  resourcemanager:prefetch({ "blobs/red.png" })
  scenemanager:set("1")

  -- local hammer = scenemanager:get("hammer")

  -- scenemanager:destroy() -- or set a new
end

function loop()
end

function run()
  engine:run()
end
