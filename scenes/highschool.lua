local scene = {}

local pool = {}

local timers = {}

local Inventory = require("overlay/inventory")

local Scribe = require("helpers/scribe")
local say = Scribe.say
local scribe = Scribe.scribe

local cassette = engine:cassette()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()

local objects = {
  gothgirl = {
    messages = {
      "I will not speak of stars, for the universe has faded away.",
    },
  },
  punkgirl = {
    messages = {
      "Reactionary discourse from state-puppet teachers.",
    },
  },
  redguy = {
    messages = {
      "The road of rebellion leads to inner power.",
    },
  },
  teacher = {
    messages = {
      "Your laziness will get you sent straight to hell.", -- I miss you, calculus professor.
    },
  },
}

function scene.on_enter()
  scenemanager:destroy("mainmenu")
  scenemanager:destroy("whobuilt")
  scenemanager:destroy("livingroom")
  scenemanager:register("pearintosh")
  cassette:set("system/stage", "highschool")

  pool.binarymessage = scene:get("binarymessage", SceneType.object)
  pool.binarymessage:on_hover(function(self)
    self.action = "default"
  end)
  pool.binarymessage:on_unhover(function(self)
    self.action = "hidden"
  end)

  pool.pearintosh = scene:get("pearintosh", SceneType.object)
  pool.pearintosh:on_touch(function()
    scribe:clear()
    scenemanager:set("pearintosh")
  end)

  pool.bloodyhandprint = scene:get("bloodyhandprint", SceneType.object)

  local id = timermanager:set(6000, function()
    pool.bloodyhandprint.action = "default"
  end)

  table.insert(timers, id)

  for name, conf in pairs(objects) do
    local object = scene:get(name, SceneType.object)

    object:on_touch(function()
      local messages = conf.messages
      local message = messages[math.random(#messages)]

      say(message, 3, 3, 3000)
    end)

    pool[name] = object
  end

  local layout = scene:get("layout", SceneType.object)
  local character = scene:get("boy", SceneType.object)
  local playboy = scene:get("playboy", SceneType.object)
  print(">>> " .. playboy.kind)
  pool.inventory = Inventory.new(layout, character, { playboy })
end

function scene.on_motion(x, y)
  pool.inventory:motion(x, y)
end

function scene.on_loop(delta)
  scribe:loop(delta)

  pool.inventory:loop(delta)
end

function scene.on_leave()
  scribe:clear()

  for _, id in ipairs(timers) do
    timermanager:clear(id)
  end

  for name in pairs(pool) do
    pool[name] = nil
  end
end

sentinel(scene, "highschool")

return scene
