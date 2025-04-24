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
local resourcemanager = engine:resourcemanager()

local postalservice = PostalService.new()

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

local function summon()
  pool.beelzebuuth.action:set("summon")
  local effect = scene:get("scream", SceneType.effect)
  effect:play()
end

local function jumpscare()
  pool.alpha = 0
  pool.skull.alpha = 0

  timermanager:singleshot(3000, function()
    local effect = scene:get("skull", SceneType.effect)
    effect:play()

    pool.skull.action:set("default")
    pool.alpha = 0

    local direction = 1
    local loop
    loop = timermanager:set(30, function()

      local dx = math.random(-3, 3)
      local dy = math.random(-3, 3)
      pool.skull.placement:set(dx, dy)

      pool.alpha = pool.alpha + (10 * direction)
      pool.alpha = math.max(0, math.min(pool.alpha, 255))
      pool.skull.alpha = pool.alpha

      if direction == 1 and pool.alpha >= 255 then
        direction = -1
      elseif direction == -1 and pool.alpha <= 0 then
        timermanager:clear(loop)
        postalservice:post(Mail.new(pool.skull, nil, "end"))
      end
    end)

    pool.skull:on_mail(function(self, message)
      pool.skull.action:unset()
      timermanager:clear(loop)
    end)
  end)
end

function scene.on_enter()
  cassette:set("system/stage", "babyroom")
  scenemanager:destroy("mainmenu")
  resourcemanager:flush()

  noise:init()

  pool.timers = {}
  pool.collected = {}

  pool.skull = scene:get("skull", SceneType.object)
  pool.skull.action:unset()
  pool.skull.alpha = 0
  pool.alpha = 0

  pool.television = scene:get("television", SceneType.object)

  pool.beelzebuuth = scene:get("beelzebuuth", SceneType.object)

  for name, configuration in pairs(timed) do
    pool[name] = scene:get(name, SceneType.object)

    local delay = math.random(configuration.minimum, configuration.maximum) * 1000

    local id = timermanager:set(delay, function()
      pool[name].action:set(configuration.action)
    end)

    table.insert(pool.timers, id)
  end

  for name, configuration in pairs(items) do
    local key = prefix .. name
    local object = scene:get(name, SceneType.object)
    pool[name] = object

    local done = cassette:get(key, false)

    pool.collected[name] = done

    if done then
      object:hide()
    else
      object:on_touch(function(self)
        if configuration.damage then
          overlay:dispatch(WidgetType.cursor, "damage")
        end

        if configuration.effect then
          local effect = scene:get(configuration.effect, SceneType.effect)
          effect:play()
        end

        pool.television.action:set("poltergeist")

        cassette:set(key, true)
        pool.collected[name] = true
        self:hide()

        for _, collected in pairs(pool.collected) do
          if not collected then
            return
          end
        end

        jumpscare()
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

  summon()
end

return scene
