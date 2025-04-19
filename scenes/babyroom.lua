local scene = {}

local noise = require("effects/noise")
local scribe = require("helpers/scribe")

local pool = {}
local lock = false
local prefix = "babyroom/"

local cassette = engine:cassette()
local overlay = engine:overlay()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()
local soundmanager = engine:soundmanager()
local resourcemanager = engine:resourcemanager()

local timed = {
  car   = { minimum = 3, maximum = 8, action = "run"   },
  bear  = { minimum = 2, maximum = 4, action = "blink" },
  clown = { minimum = 6, maximum = 8, action = "blink" },
  robot = { minimum = 3, maximum = 6, action = "shake" },
}

local items = {
  crucifix = { effect = "wind",  damage = true,  hint = "His sacrifice means nothing" },
  gijoe    = { effect = "door",  damage = false, hint = "Covert missions demand unbreakable resolve" },
  nintendo = { effect = "metal", damage = false, hint = "Joy fades leaving glitching code" },
  playboy  = { effect = "gore",  damage = false, hint = "Velvet whispers ignite hidden passions" },
}

function scene.on_enter()
  cassette:set("system/stage", "babyroom")
  scenemanager:destroy("mainmenu")
  resourcemanager:flush()

  noise:init()

  pool.timers = {}

  pool.television = scene:get("television")

  pool.beelzebuuth = scene:get("beelzebuuth")

  for name, configuration in pairs(timed) do
    pool[name] = scene:get(name)

    local delay = math.random(configuration.minimum, configuration.maximum) * 1000

    local id = timermanager:set(delay, function()
      pool[name].action:set(configuration.action)
    end)

    table.insert(pool.timers, id)
  end

  for name, configuration in pairs(items) do
    local key = prefix .. name
    local object = scene:get(name)
    pool[name] = object

    local done = cassette:get(key, false)
    if done then
      object:hide()
    end

    if not done then
      object:on_touch(function(self)
        if configuration.damage then
          overlay:dispatch(Widget.cursor, "damage")
        end

        if configuration.effect then
          soundmanager:play(prefix .. configuration.effect)
        end

        pool.television.action:set("poltergeist")

        cassette:set(key, true)

        self:hide()
      end)
    end
  end

  noise:on_finish(function()
    scribe:write("I drown your divinity in the Acheron of my soul", 3, 3)
    scribe:on_finish(12000, function() scribe:clear() end)
  end)
end

function scene.on_loop()
  noise:loop()
end

function scene.on_leave()
  noise:teardown()

  for _, id in ipairs(pool.timers) do
    timermanager:clear(id)
  end

  pool.timers = {}

  pool = {}
end

function scene.on_touch()
  if lock then
    return
  end

  pool.touches = (pool.touches or 0) + 1
  pool.threshold = pool.threshold or math.random(3, 6)

  if pool.touches < pool.threshold then
    return
  end

  pool.touches = 0
  pool.threshold = math.random(3, 6)

  local candidates = {}
  for name in pairs(items) do
    if not cassette:get(prefix .. name, false) then
      table.insert(candidates, name)
    end
  end

  if math.random() < 0.8 and #candidates > 0 then
    lock = true

    local chosen = candidates[math.random(#candidates)]

    scribe:clear()
    scribe:write(items[chosen].hint, 3, 3)
    scribe:on_finish(3000, function()
      scribe:clear()
      lock = false
    end)

    return
  end

  pool.beelzebuuth.action:set("summon")
  soundmanager:play(prefix .. "scream")
end

return scene
