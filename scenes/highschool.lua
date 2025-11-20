local scene = {}

local Inventory = require("overlay/inventory")

local jump = require("helpers/jump")
local scribe = require("helpers/scribe")
local say = scribe.say

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
      "Did you see what happened in the chemistry lab?",
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
      "Did you know you can write an OS in C++?",
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
  state.system.stage = "highschool"

  transition({
    destroy = { "mainmenu", "whobuilt", "livingroom" },
    register = { "pearintosh" },
  })

  pool.binarymessage = scene:get("binarymessage", SceneKind.object)
  pool.binarymessage:on_hover(function(self)
    self.action = "default"
  end)
  pool.binarymessage:on_unhover(function(self)
    self.action = "hidden"
  end)

  pool.pearintosh = scene:get("pearintosh", SceneKind.object)
  pool.pearintosh:on_touch(jump.to("pearintosh"))

  pool.bloodyhandprint = scene:get("bloodyhandprint", SceneKind.object)

  timermanager:set(6666, function()
    pool.bloodyhandprint.action = "default"
  end)

  pool.sourcecode = scene:get("sourcecode", SceneKind.object)
  pool.minisourcecode = scene:get("minisourcecode", SceneKind.object)
  pool.minisourcecode:on_touch(function()
    if pool.sourcecode.action ~= "default" then
      pool.sourcecode.action = "default"
    else
      pool.sourcecode.action = nil
    end
  end)

  for name, conf in pairs(objects) do
    local object = scene:get(name, SceneKind.object)

    object:on_touch(function()
      if pool.sourcecode.action == "default" then
        return
      end

      local kind = pool.inventory.dragging
      if kind ~= nil then
        if conf.receivables then
          local reaction = conf.receivables[kind]
          if reaction.gameover then
            -- TODO show game over screen
            return
          end

          if reaction.accept then
            state.sourcecode = true
            pool.minisourcecode.action = "default"
            pool.inventory.release()
          end

          local messages = reaction.messages
          local message = messages[math.random(#messages)]
          say(message, 3, 3, 3000)
        end
        return
      end

      local messages = conf.messages
      local count = #messages
      local index = math.random(count)
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

  local layout = scene:get("layout", SceneKind.object)
  local character = scene:get("boy", SceneKind.object)
  local magazine = scene:get("HUD/playboy", SceneKind.object)
  pool.inventory = Inventory.new(layout, character, { magazine })

  if state.sourcecode then
    pool.minisourcecode.action = "default"
    magazine.action = nil
  end
end

function scene.on_motion(x, y)
  pool.inventory.motion(x, y)
end

function scene.on_touch() end

function scene.on_loop(delta)
  scribe.loop(delta)

  pool.inventory.loop(delta)
end

function scene.on_leave()
  scribe.clear()
  pool.inventory.teardown()
end

sentinel(scene, "highschool")

return scene
