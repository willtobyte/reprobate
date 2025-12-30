local scene = {}

local tween = require("library/tween")
local tweens = require("helpers/tweens")
local scribe = require("helpers/scribe")

local hideable = {
  "antiquewallclock",
  "baphomet",
  "bloodpriest",
  "pictures",
  "mirrors",
  "ogremask",
  "window",
}

local items = {
  sugarcanespirit = {},
  voodoodoll = {},
}

local function verify()
  if not all(items, "taken") then
    return
  end

  state.system.stage = "highschool"
  pool.gettingintometal:play()

  timermanager:singleshot(2000, function()
    scribe.clear()

    for _, name in ipairs(hideable) do
      if pool[name] then
        pool[name].visible = false
      end
    end

    pool.cabinetdoor.visible = false
    pool.teenager.action = "default"
    pool.teenager.alpha = 200
    tweens.appear.teenager = tween.new(3, pool.teenager, { alpha = 255 })
  end)

  timermanager:singleshot(5000, function()
    pool.teenager.action = nil
    pool.teenager.action = "default"
    pool.voodoocast.action = "default"
    pool.voodoocast.alpha = 0
    tweens.appear.voodoocast = tween.new(3, pool.voodoocast, { alpha = 255 })
  end)

  timermanager:singleshot(9000, function()
    pool.teenager:on_touch(jump.to("highschool"))
  end)
end

function scene.on_enter()
  state.system.stage = "livingroom"

  transition({
    destroy = { "mainmenu", "whobuilt", "babyroom" },
    register = { "highschool" },
  })

  pool.rainmuffled:play(true)

  if state.cabinetdoor then
    pool.cabinetdoor.action = "open"
    pool.voodoodoll.action = "default"
  else
    pool.cabinetdoor:on_touch(function()
      pool.cabinetdoor:on_touch(nil)
      state.cabinetdoor = true
      pool.cabinetdoor.action = "open"
      pool.voodoodoll.action = "default"
      pool.voodoodoll.alpha = 0
      tweens.appear.voodoodoll = tween.new(1, pool.voodoodoll, { alpha = 255 })
      scribe.say("The doll is not yours, it belongs to the loa that rides it.", 3, 3, 3000)
    end)
  end

  for name, conf in pairs(items) do
    local object = pool[name]

    conf.taken = not not state[name]
    object.visible = not conf.taken
    object:on_touch(function()
      object:on_touch(nil)
      if conf.taken then
        return
      end

      conf.taken = true
      state[name] = true
      tweens.disappear[name] = tween.new(1, object, { alpha = 0, angle = 360, scale = 1.6 }, "inOutQuad")

      verify()
    end)
  end
end

function scene.on_loop(delta)
  scribe.loop(delta)

  tweens.loop(delta, function(type, name, t)
    if t.subject and type == "disappear" then
      t.subject.visible = false
    end
  end)
end

function scene.on_leave()
  scribe.clear()
  tweens.teardown()
end

sentinel(scene, "livingroom")

return scene
