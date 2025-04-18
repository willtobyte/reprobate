local scene = {}

local noise = require("effects/noise")
local scribe = require("helpers/scribe")

local pool = {}
local prefix = "babyroom/"

local cassette = engine:cassette()
local overlay = engine:overlay()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()
local soundmanager = engine:soundmanager()

local timed = {
  car   = { minimum = 3, maximum = 8, action = "run"   },
  bear  = { minimum = 2, maximum = 4, action = "blink" },
  clown = { minimum = 6, maximum = 8, action = "blink" },
  robot = { minimum = 3, maximum = 6, action = "shake" },
}

local items = {
  crucifix = { sound = "wind",  damage = true,  hint = "His sacrifice means nothing" },
  gijoe    = { sound = "door",  damage = false, hint = "Covert missions demand unbreakable resolve" },
  nintendo = { sound = "metal", damage = false, hint = "Joy fades leaving glitching code" },
  playboy  = { sound = "gore",  damage = false, hint = "Velvet whispers ignite hidden passions" },
}

function scene.on_enter()
  cassette:set("system/stage", "babyroom")
  noise.init()

  pool.timers = {}

  for name, config in pairs(timed) do
    pool[name] = scene:get(name)
    local delay = math.random(config.minimum, config.maximum) * 1000
    local handle = timermanager:set(delay, function()
      pool[name].action:set(config.action)
    end)
    table.insert(pool.timers, handle)
  end

  for name, config in pairs(items) do
    local key   = prefix .. name
    local object   = scene:get(name)
    pool[name]  = obj

    local done = cassette:get(key, false)
    if done then
      object:hide()
    end

    if not done then
      object:on_touch(function(self)
        if config.damage then
          overlay:dispatch(Widget.cursor, "damage")
        end
        if config.sound then
          soundmanager:play(config.sound)
        end

        pool.television.action:set("poltergeist")
        self:hide()
        cassette:set(key, true)
      end)
    end
  end

  pool.television = scene:get("television")

  pool.beelzebuuth = scene:get("beelzebuuth")

  noise.on_finish(function()
    scribe.write("I drown your holiness in the Acheron of my soul", 3, 3)
    scribe.on_finish(12000, scribe.clear)
  end)
end

function scene.on_loop()
  noise.loop()
end

function scene.on_leave()
  noise.teardown()

  for _, handle in ipairs(pool.timers) do
    timermanager:clear(handle)
  end

  for key in pairs(pool) do
    pool[key] = nil
  end
end

function scene.on_touch()
  if pool.lock then
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
    pool.lock = true
    local chosen = candidates[math.random(#candidates)]
    scribe.clear()
    scribe.write(items[chosen].hint, 3, 3)
    scribe.on_finish(3000, function()
      scribe.clear()
      pool.lock = false
    end)
    return
  end

  pool.beelzebuuth.action:set("summon")
  soundmanager:play("scream")
end

return scene
