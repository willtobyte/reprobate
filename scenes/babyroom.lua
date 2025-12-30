local scene = {}

local Inventory = require("overlay/inventory")

local tween = require("library/tween")
local tweens = require("helpers/tweens")

local ops = require("helpers/ops")
local prank = require("helpers/prank")

local scribe = require("helpers/scribe")
local say = scribe.say

local items = {
  crucifix = { damage = true },
  gijoe = {},
  nintendo = {},
  playboy = {},
}

local function verify()
  if all(items, "taken") then
    state.system.stage = "livingroom"

    pool.door.action = "default"

    timermanager:singleshot(3000, function()
      pool.doorsound:play()
      pool.door:on_touch(jump.to("livingroom"))
    end)
  end
end

function scene.on_enter()
  state.system.stage = "babyroom"

  transition({
    destroy = { "mainmenu", "whobuilt" },
    register = { "livingroom" },
  })

  prank.write("We Have A Connection.txt", "TODO...")

  pool.beelzebuuth.misses:subscribe(function(value)
    if value >= 6 then
      pool.beelzebuuth.action = "summon"
      pool.scream:play()
      pool.beelzebuuth.misses = 0
    end
  end)

  local objects = {}

  for name, conf in pairs(items) do
    local object = pool[name]

    local hud = "HUD/" .. name
    local item = pool[hud]
    table.insert(objects, item)

    conf.taken = state[name] == true

    if conf.taken then
      object.visible = false
      item.action = "default"
    else
      object:on_touch(function()
        object:on_touch(nil)
        if conf.damage then
          overlay:dispatch(WidgetType.cursor, "damage")
        end

        pool.television.action = "poltergeist"
        conf.taken = true
        state[name] = true

        tweens.disappear[name] = tween.new(1, object, { alpha = 0, angle = 360, scale = 1.6 }, "inOutQuad")
        pool[hud].action = "default"

        verify()
      end)
    end
  end

  pool.inventory = Inventory.new(pool.layout, pool.boy, objects)

  say("I drown your divinity in the acheron of my soul.", 3, 3, 12000)
end

function scene.on_touch()
  ops.incr(pool.beelzebuuth.misses)
end

function scene.on_motion(x, y)
  pool.inventory.motion(x, y)
end

function scene.on_loop(delta)
  scribe.loop(delta)
  pool.inventory.loop(delta)
  tweens.loop(delta, function(type, name, t)
    if t.subject and type == "disappear" then
      t.subject.visible = false
    end
  end)
end

function scene.on_leave()
  scribe.clear()

  tweens.teardown()
  pool.inventory.teardown()
end

sentinel(scene, "babyroom")

return scene
