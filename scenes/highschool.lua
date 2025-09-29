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
      "I feel the vibrations of the moon.",
    },
  },
  punkgirl = {
    messages = {
      "Reactionary discourse from state-puppet teachers.",
      "Wake the hell up, kill the TV. Forget your idols & face yourself.",
    },
    receivables = {
      ["HUD/playboy"] = {
        messages = {
          "Take this and shove it up your ass.",
        },
      },
    },
  },
  redguy = {
    messages = {
      "The road of rebellion leads to inner power.",
      "The Will to Potency.\nThe Will to Potency.\nThe Will to Potency.\nThe Will to Potency.",
    },
    receivables = {
      ["HUD/playboy"] = {
        messages = {
          "Keep this away from me. You pevert.",
        },
      },
    },
  },
  teacher = {
    messages = {
      "Your laziness will get you sent straight to hell.",
    },
    receivables = {
      ["HUD/playboy"] = {
        gameover = true,
      },
    },
  },
  thenerd = {
    messages = {
      "I first learned LOGO, and now I study BASIC.",
      "I am learning C. Pointers are awesome!",
    },
    receivables = {
      ["HUD/playboy"] = {
        accept = true,
        messages = {
          "Thank you! I have been searching for years for this edition.\nTake this.",
        },
      },
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

  local id = timermanager:set(6666, function()
    pool.bloodyhandprint.action = "default"
  end)

  table.insert(timers, id)

  for name, conf in pairs(objects) do
    local object = scene:get(name, SceneType.object)

    object:on_touch(function()
      local kind = pool.inventory.dragging
      if kind ~= nil then
        if conf.receivables then
          local reaction = conf.receivables[kind]
          if reaction.gameover then
            print("game over")
            return
          end

          if reaction.accept then
            pool.inventory:release()
          end

          local messages = reaction.messages
          local message = messages[math.random(#messages)]
          say(message, 3, 3, 3000)

          return
        end
      end

      local messages = conf.messages
      local message = messages[math.random(#messages)]
      say(message, 3, 3, 3000)
    end)

    pool[name] = object
  end

  local layout = scene:get("layout", SceneType.object)
  local character = scene:get("boy", SceneType.object)
  local playboy = scene:get("playboy", SceneType.object)
  pool.inventory = Inventory.new(layout, character, { playboy })
end

function scene.on_motion(x, y)
  pool.inventory:motion(x, y)
end

function scene.on_touch()
  print("touch")
end

function scene.on_loop(delta)
  scribe:loop(delta)

  pool.inventory:loop(delta)
end

function scene.on_leave()
  pool.inventory:teardown()
  pool.inventory = nil

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
