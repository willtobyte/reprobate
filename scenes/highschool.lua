local scene = {}

local pool = {}

local Inventory = require("overlay/inventory")

local Scribe = require("helpers/scribe")
local say = Scribe.say
local scribe = Scribe.scribe

local cassette = engine:cassette()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()

local playboy = "HUD/playboy"

local objects = {
  blondgirl = {
    messages = {
      "Have you finished your homework yet?",
      "People say the cafeteria ground beef is human.",
    },
    receivables = {
      [playboy] = {
        messages = {
          "The pages are all stuck together. Modern art, probably.",
        },
      },
    },
  },
  bulletinboard = {
    messages = {
      "Blood Club Meeting, Tuesday 3PM",
      "Lost: Black metal vinyl. Kindly return to the main office.",
      "Spectral auditions next week!",
    },
  },
  gothgirl = {
    messages = {
      "I will not speak of stars, for the universe has faded away.",
      "Shattered embers of ancient stars, wandering in flesh.",
      "Darkness is not the absence of light, it is the abyss itself.",
    },
    receivables = {
      [playboy] = {
        messages = {
          "How adorable. You mistook me for someone alive inside.",
        },
      },
    },
  },
  longhairgirl = {
    messages = {
      "My parents want me to study medicine, I love computers.",
      "Did you see what happened in the chemistry lab?",
    },
  },
  punkgirl = {
    messages = {
      "Reactionary discourse from state-puppet teachers.",
      "Turn off the TV, forget your idols, and face yourself.",
      "Tune in to our pirate radio station on 43.2 FM.",
    },
    receivables = {
      [playboy] = {
        messages = {
          "Take this and shove it up your ass hole.",
          "Is that your mom on the cover?",
        },
      },
    },
  },
  purplegirl = {
    messages = {
      "If all this fades into gray and absence?",
      "Want to study together after school?",
      "I heard there is a secret room behind the library.",
    },
    receivables = {
      [playboy] = {
        messages = {
          "Let me guess, you thought this was romantic?",
        },
      },
    },
  },
  purpleman = {
    messages = {
      "And what if none of this ever truly mattered?",
      "The false dream they dreamed on our behalf.",
    },
    receivables = {
      [playboy] = {
        messages = {
          "So this is what you think I read in my spare time? Touching.",
        },
      },
    },
  },
  redguy = {
    achievement = {
      index = 2,
      id = "ACH_THE_WILL_TO_POTENCY",
    },
    messages = {
      "The road of rebellion leads to inner power.",
      "The Will to Potency.\nThe Will to Potency.\nThe Will to Potency.", -- Always update `achievement.index`.
      "I have some zines, feel free to grab one.", -- Always update `delivers.index`.
    },
    receivables = {
      [playboy] = {
        messages = {
          "Keep this away from me. You pevert.",
        },
      },
    },
    deliver = {
      index = 3,
      id = "zine",
    },
  },
  teacher = {
    messages = {
      "Your laziness will get you sent straight to hell.",
      "Everyone, open page 42 of The C Programming Language book.",
    },
    receivables = {
      [playboy] = {
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
      [playboy] = {
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

  timermanager:set(6666, function()
    pool.bloodyhandprint.action = "default"
  end)

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

      if conf.achievement and index == conf.achievement.index then
        achievement:unlock(conf.achievement.id)
      end

      if conf.deliver and index == conf.deliver.index then
        print(">>> TODO got zine")
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

function scene.on_touch() end

function scene.on_loop(delta)
  scribe:loop(delta)

  pool.inventory:loop(delta)
end

function scene.on_leave()
  pool.inventory:teardown()

  scribe:clear()

  for name in next, pool do
    pool[name] = nil
  end
end

sentinel(scene, "highschool")

return scene
