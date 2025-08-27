local scene = {}

local Inventory = require("overlay/inventory")
local noise = require("effects/noise")
local scribe = require("helpers/scribe")
local visibility = require("helpers/visibility")

local R = math.random
local pairs = pairs
local ipairs = ipairs
local insert = table.insert

local pool = {}
local prefix = "babyroom/"

local cassette = engine:cassette()
local overlay = engine:overlay()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()

local animations = {
  car = { minimum = 5, maximum = 12, action = "run", message = "Twisted dream. Metal price." },
  bear = { minimum = 4, maximum = 10, action = "blink", message = "Do you want to play for five nights at my house?" },
  clown = {
    minimum = 6,
    maximum = 18,
    action = "blink",
    message = "A cosmic clown is closing in. Not here for laughs.",
  },
  robot = { minimum = 3, maximum = 13, action = "shrug", message = "Need more input!" },
}

local items = {
  crucifix = { damage = true, hint = "His sacrifice means nothing." },
  gijoe = { damage = false, hint = "Plastic bones beneath the dust of war." },
  nintendo = { damage = false, hint = "Wires like veins, still twitching." },
  playboy = { damage = false, hint = "Paper temptations sealed behind sin." },
}

local function say(msg, x, y, ms)
  scribe:clear()
  scribe:write(msg, x or 3, y or 3)
  scribe:on_finish(ms or 3000, function()
    scribe:clear()
  end)
end

function scene.on_enter()
  noise:init()

  scenemanager:destroy("mainmenu")
  scenemanager:destroy("whobuilt")
  scenemanager:register("livingroom")

  cassette:set("system/stage", "babyroom")

  pool.timers = {}
  pool.collected = {}
  pool.uncollected = {}
  pool.unset = {}
  pool.remaining = 0
  pool.missclicks = 0
  pool.touches = 0
  pool.threshold = R(3, 6)

  pool.theme = scene:get("theme", SceneType.effect)
  pool.theme:play(true)

  pool.television = scene:get("television", SceneType.object)
  pool.beelzebuuth = scene:get("beelzebuuth", SceneType.object)

  pool.television:on_touch(function()
    say("This game is haunted, can you feel it?", 3, 3, 6000)
  end)

  for name, settings in pairs(animations) do
    local object = scene:get(name, SceneType.object)
    pool[name] = object
    local action = settings.action
    local message = settings.message
    local delay_ms = R(settings.minimum, settings.maximum) * 1000

    local tid = timermanager:set(delay_ms, function()
      if pool[name] then
        pool[name].action = action
      end
    end)
    insert(pool.timers, tid)

    object:on_touch(function()
      say(message, 3, 3, 3000)
    end)
  end

  local objects = {}
  for name, settings in pairs(items) do
    local key = prefix .. name
    local object = scene:get(name, SceneType.object)
    local iname = "i" .. name
    local iobject = scene:get(iname, SceneType.object)

    pool[name] = object
    pool[iname] = iobject

    local done = cassette:get(key, false)
    pool.collected[name] = done

    if not done then
      insert(objects, iobject)
    end

    if done then
      object:hide()
      iobject.action = "default"
      if iobject.hide then
        iobject:hide()
      end
      pool[iname] = nil
    end

    if not done then
      pool.remaining = pool.remaining + 1
      insert(pool.uncollected, name)
      pool.unset[name] = true

      local captured_name = name
      local captured_iname = iname

      object:on_touch(function(self)
        if settings.damage then
          overlay:dispatch(WidgetType.cursor, "damage")
        end

        pool.television.action = "poltergeist"
        pool.collected[captured_name] = true
        cassette:set(prefix .. captured_name, true)

        visibility.disappear(self)

        local icon = pool[captured_iname]
        if icon then
          icon.action = "default"
          if pool.inventory and pool.inventory.remove then
            pool.inventory:remove(icon)
          end
          if icon.hide then
            icon:hide()
          end
          pool[captured_iname] = nil
        end

        if pool.unset[captured_name] then
          pool.unset[captured_name] = nil
          for i, v in ipairs(pool.uncollected) do
            if v == captured_name then
              pool.uncollected[i] = pool.uncollected[#pool.uncollected]
              pool.uncollected[#pool.uncollected] = nil
              break
            end
          end
          pool.remaining = pool.remaining - 1
        end

        if pool.remaining ~= 0 then
          return
        end

        cassette:set("system/stage", "livingroom")

        local tid1 = timermanager:singleshot(1000, function()
          local door = scene:get("door", SceneType.object)
          door:on_touch(function()
            scribe:clear()
            scenemanager:set("livingroom")
          end)
          door.action = "default"

          local tid2 = timermanager:singleshot(3000, function()
            local effect = scene:get("door", SceneType.effect)
            effect:play()
          end)
          insert(pool.timers, tid2)
        end)
        insert(pool.timers, tid1)
      end)
    end
  end

  local layout = scene:get("layout", SceneType.object)
  local character = scene:get("boy", SceneType.object)
  pool.inventory = Inventory.new(layout, character, objects)

  noise:on_finish(function()
    say("I drown your divinity in the acheron of my soul.", 4, 5, 12000)
  end)
end

function scene.on_loop(delta)
  noise:loop()
  scribe:loop(delta)
  pool.inventory:loop(delta)
end

function scene.on_touch()
  pool.missclicks = pool.missclicks + 1
  if pool.missclicks >= 6 then
    pool.beelzebuuth.action = "summon"
    pool.missclicks = 0
    return
  end

  pool.touches = pool.touches + 1
  if pool.touches < pool.threshold then
    return
  end

  pool.threshold = R(3, 6)
  pool.touches = 0

  local n = #pool.uncollected
  if n > 0 and R(0, 99) < 80 then
    local chosen = pool.uncollected[R(1, n)]
    say(items[chosen].hint, 3, 3, 3000)
    return
  end
end

function scene.on_motion(x, y)
  pool.inventory:on_motion(x, y)
end

function scene.on_leave()
  noise:teardown()
  for _, id in ipairs(pool.timers) do
    timermanager:clear(id)
  end
  if pool.inventory and pool.inventory.teardown then
    pool.inventory:teardown()
  end
  pool = {}
end

return scene
