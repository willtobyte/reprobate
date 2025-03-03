---@diagnostic disable: undefined-global, undefined-field, lowercase-global
_G.engine             = EngineFactory.new()
    :with_title("Reprobate")
    :with_width(1920)
    :with_height(1080)
    :with_scale(4.0)
    :with_fullscreen(false)
    :create()

--local entitymanager   = engine:entitymanager()
local cassete         = engine:cassete()
local resourcemanager = engine:resourcemanager()
local scenemanager    = engine:scenemanager()

function setup()
  resourcemanager:prefetch({ "blobs/red.png" })
  scenemanager:set("1")

  -- local hammer = scenemanager:get("hammer 1")

  -- scenemanager:destroy() -- or set a new
  --
  cassete:set("foo", "bar")
  print(cassete:get("foo"))
end

function loop()
end

function run()
  engine:run()
end
