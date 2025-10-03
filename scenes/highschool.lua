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
  blondgirl = {
    messages = {
      "Have you finished your homework yet?",
      "People say the cafeteria ground beef is human.",
    },
  },
  bulletinboard = {
    messages = {
      "Blood Club Meeting - Tuesday 3PM",
      "Lost: Venom - Black Metal vinyl. Please return to main office.",
      "Spectral auditions next week!",
    },
  },
  gothgirl = {
    messages = {
      "I will not speak of stars, for the universe has faded away.",
      "I feel the vibrations of the moon.",
      "Darkness is not the absence of light.",
    },
  },
  longhairgirl = {
    messages = {
      "My parents want me to study medicine, I actually love computers.",
      "Did you see what happened in the chemistry lab?",
    },
  },
  punkgirl = {
    messages = {
      "Reactionary discourse from state-puppet teachers.",
      "Wake the hell up, kill the TV. Forget your idols & face yourself.",
      "They want us to conform, but I refuse to be another brick.",
    },
    receivables = {
      ["HUD/playboy"] = {
        messages = {
          "Take this and shove it up your ass.",
        },
      },
    },
  },
  purplegirl = {
    messages = {
      "Math class is my favorite, weird right?",
      "Want to study together after school?",
      "I heard there's a secret room behind the library.",
    },
  },
  purpleman = {
    messages = {
      "The basketball team is looking for new players.",
      "I failed the history test... again.",
      "Anyone want to grab pizza after school?",
    },
  },
  redguy = {
    achievement = {
      trigger_index = 2,
      id = "ACH_THE_WILL_TO_POTENCY",
    },
    messages = {
      "The road of rebellion leads to inner power.",
      "The Will to Potency.\nThe Will to Potency.\nThe Will to Potency.\nThe Will to Potency.", -- Always update `trigger_index`.
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
      "Everyone, open page 42 of The C Programming Language book.",
    },
    receivables = {
      ["HUD/playboy"] = {
        gameover = true,
      },
    },
  },
  thenerd = {
    messages = {
      "I am learning C. Pointers are awesome!",
      "General protection fault? What the heck is going on?",
      "Did you know you can write an OS in assembly?",
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
  wallclock = {
    messages = {
      "The clock seems to be moving slower today.",
      "Tick... Tock... Tick... Tock...",
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
            -- TODO show game over screen
            return
          end

          if reaction.accept then
            -- TODO add script to inventory
            pool.inventory:release()
          end

          local messages = reaction.messages
          local message = messages[math.random(#messages)]
          say(message, 3, 3, 3000)
        end
        return
      end

      local messages = conf.messages
      local last = #messages
      local index = math.random(last)
      local message = messages[index]

      if conf.achievement and index == conf.achievement.trigger_index then
        achievement:unlock(conf.achievement.id)
      end

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

  for i = 1, #timers do
    timermanager:clear(timers[i])
  end

  for name in next, pool do
    pool[name] = nil
  end
end

sentinel(scene, "highschool")

return scene
