local scene = {}

local pool = {}

local Inventory = require("overlay/inventory")

local tween = require("library/tween")

local ops = require("helpers/ops")
local prank = require("helpers/prank")
local jump = require("helpers/jump")
local Scribe = require("helpers/scribe")
local say = Scribe.say
local scribe = Scribe.scribe

local animations = {
  car = {
    minimum = 5,
    maximum = 12,
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
    maximum = 18,
    action = "blink",
    message = "A cosmic clown is closing in. Not here for laughs.",
  },
  robot = {
    minimum = 3,
    maximum = 13,
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
  if all(pool.collected) then
    state.system.stage = livingroom

    -- achievement:unlock("")

    timermanager:singleshot(1000, function()
      pool.door = scene:get("door", SceneType.object)
      pool.door:on_touch(jump.to("livingroom"))

      pool.door.action = "default"

      timermanager:singleshot(3000, function()
        pool.effect = scene:get("door", SceneType.effect)
        pool.effect:play()
      end)
    end)
  end
end

function scene.on_enter()
  state.system.stage = "babyroom"

  transition({
    destroy = { "mainmenu", "whobuilt" },
    register = { "livingroom" },
  })

  prank.write("I See You.txt", "TODO...")

  pool.tweens = {}
  pool.collected = {}
  pool.television = scene:get("television", SceneType.object)
  pool.beelzebuuth = scene:get("beelzebuuth", SceneType.object)

  pool.beelzebuuth.misses:subscribe(function(value)
    if value >= 6 then
      pool.beelzebuuth.action = "summon"
      pool.beelzebuuth.misses = 0
    end
  end)

  pool.television:on_touch(function()
    say("This game is haunted, can you feel it?")
  end)

  for name, conf in pairs(animations) do
    local message = conf.message
    local object = scene:get(name, SceneType.object)
    pool[name] = object

    local delay = math.random(conf.minimum, conf.maximum) * 1000
    local action = conf.action
    timermanager:set(delay, function()
      pool[name].action = action
    end)

    object:on_touch(function()
      say(message)
    end)
  end

  local objects = {}

  for name, conf in pairs(items) do
    local object = scene:get(name, SceneType.object)
    pool[name] = object

    local hud = "HUD/" .. name
    local item = scene:get(hud, SceneType.object)
    pool[hud] = item
    table.insert(objects, item)

    local taken = state[name] or false

    pool.collected[name] = taken

    if taken then
      object.visible = false
      item.action = "default"
    else
      object:on_touch(function(self)
        if conf.damage then
          overlay:dispatch(WidgetType.cursor, "damage")
        end

        pool.television.action = "poltergeist"
        pool.collected[name] = true

        -- cassette:set(key, true)
        state[name] = true
        pool.tweens[#pool.tweens + 1] = tween.new(1, self, { alpha = 0, angle = 360, scale = 1.5 }, "inOutQuad")
        pool[hud].action = "default"

        verify()
      end)
    end
  end

  local layout = scene:get("layout", SceneType.object)
  local character = scene:get("boy", SceneType.object)
  pool.inventory = Inventory.new(layout, character, objects)

  say("I drown your divinity in the acheron of my soul.", 3, 3, 12000)
end

function scene.on_touch()
  ops.incr(pool.beelzebuuth.misses)
end

function scene.on_motion(x, y)
  pool.inventory:motion(x, y)
end

function scene.on_loop(delta)
  scribe:loop(delta)

  pool.inventory:loop(delta)

  local n = #pool.tweens
  if n == 0 then
    return
  end

  for i = n, 1, -1 do
    local t = pool.tweens[i]
    if t:update(delta) then
      if t.subject then
        t.subject.visible = false
      end

      pool.tweens[i] = pool.tweens[n]
      pool.tweens[n] = nil
      n = n - 1
    end
  end
end

function scene.on_leave()
  scribe:clear()
  pool.inventory:teardown()

  pool = {}
end

sentinel(scene, "babyroom")

return scene
