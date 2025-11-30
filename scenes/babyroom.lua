local scene = {}

local Inventory = require("overlay/inventory")

local tween = require("library/tween")
local tweens = require("helpers/tweens")

local camera = require("camera")
local ops = require("helpers/ops")
local prank = require("helpers/prank")

local scribe = require("helpers/scribe")
local say = scribe.say

local animations = {
  car = {
    minimum = 5,
    maximum = 8,
    action = "run",
    message = "Twisted dream. Metal price.",
  },
  bear = {
    minimum = 4,
    maximum = 10,
    action = "blink",
    message = "Do you want to play for five nights at my house?",
  },
  clown = {
    minimum = 6,
    maximum = 9,
    action = "blink",
    message = "A cosmic clown is closing in. Not here for laughs.",
  },
  robot = {
    minimum = 3,
    maximum = 8,
    action = "shrug",
    message = "Need more input!",
  },
}

local items = {
  crucifix = { damage = true },
  gijoe = {},
  nintendo = {},
  playboy = {},
}

local function verify()
  if all(items, "taken") then
    state.system.stage = "livingroom"

    -- achievement:unlock("")

    pool.effect = scene:get("door", SceneKind.effect)
    pool.door = scene:get("door", SceneKind.object)
    pool.door.action = "default"

    timermanager:singleshot(3000, function()
      pool.effect:play()
      pool.door:on_touch(jump.to("livingroom"))
    end)
  end
end

function scene.on_enter()
  state.system.stage = "livingroom"

  transition({
    destroy = { "mainmenu", "whobuilt" },
    register = { "livingroom" },
  })

  prank.write("We Have A Connection.txt", "TODO...")

  pool.television = scene:get("television", SceneKind.object)
  pool.beelzebuuth = scene:get("beelzebuuth", SceneKind.object)
  pool.scream = scene:get("scream", SceneKind.effect)

  pool.beelzebuuth.misses:subscribe(function(value)
    if value >= 6 then
      pool.beelzebuuth.action = "summon"
      pool.scream:play()
      pool.beelzebuuth.misses = 0
    end
  end)

  pool.television:on_touch(function()
    say("This game is haunted, can you feel it?")
  end)

  for name, conf in pairs(animations) do
    local message = conf.message
    local object = scene:get(name, SceneKind.object)
    pool[name] = object

    local delay = math.random(conf.minimum, conf.maximum) * 1000
    local action = conf.action

    local target = object
    timermanager:set(delay, function()
      target.action = action
    end)

    target:on_touch(function()
      say(message)
    end)
  end

  local objects = {}

  for name, conf in pairs(items) do
    local object = scene:get(name, SceneKind.object)
    pool[name] = object

    local hud = "HUD/" .. name
    local item = scene:get(hud, SceneKind.object)
    pool[hud] = item
    table.insert(objects, item)

    conf.taken = state[name] == true

    if conf.taken then
      object.visible = false
      item.action = "default"
    else
      object:on_touch(function(self)
        object:on_touch(nil)
        if conf.damage then
          overlay:dispatch(WidgetType.cursor, "damage")
        end

        pool.television.action = "poltergeist"
        conf.taken = true
        state[name] = true

        tweens.disappear[name] = tween.new(1, self, { alpha = 0, angle = 360, scale = 1.6 }, "inOutQuad")
        pool[hud].action = "default"

        verify()
      end)
    end
  end

  local layout = scene:get("layout", SceneKind.object)
  local character = scene:get("boy", SceneKind.object)
  pool.inventory = Inventory.new(layout, character, objects)

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

function scene.on_camera(delta)
  return camera.calculate(delta)
end

function scene.on_leave()
  scribe.clear()

  tweens.teardown()
  pool.inventory.teardown()
end

sentinel(scene, "babyroom")

return scene
