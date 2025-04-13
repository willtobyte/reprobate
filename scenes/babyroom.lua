local noise = require("effects/noise")

local scene = {}

local pool = {}

local overlay = engine:overlay()
local cassette = engine:cassette()
local fontfactory = engine:fontfactory()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()
local soundmanager = engine:soundmanager()

pool.label = nil

local function write(text, x, y)
  if pool.timer then
    timermanager:clear(pool.timer)
    pool.timer = nil
  end

  pool.text = text
  pool.index = 0
  pool.label:set("", x, y)

  local function tick()
    pool.index = pool.index + 1
    pool.label:set(text:sub(1, pool.index), x, y)
    if pool.index >= #text then
      timermanager:clear(pool.timer)
      pool.timer = nil
    end
  end

  pool.timer = timermanager:set(100, tick)
end

function scene.on_enter()
  pool.label = overlay:create(WidgetType.label)
  pool.label.font = fontfactory:get("evilvampire") -- "kreepykrawly"

  pool.timers = {}

  for _, o in ipairs({
    { name = "car",  min = 3, max = 8, action = "run" },
    { name = "bear", min = 2, max = 4, action = "blink" },
    { name = "clown", min = 6, max = 8, action = "blink" },
    { name = "robot", min = 3, max = 6, action = "shake" },
  }) do
    pool[o.name] = scene:get(o.name)
    local delay = math.random(o.min, o.max) * 1000
    local id = timermanager:set(delay, function()
      pool[o.name].action:set(o.action)
    end)
    table.insert(pool.timers, id)
  end

  pool.television = scene:get("television")

  for _, item in ipairs({
    { name = "crucifix", sound = "wind", damage = true },
    { name = "gijoe", sound = "door" },
    { name = "nintendo", sound = "metal" },
    { name = "playboy", sound = "gore" }
  }) do
    local key = "babyroom/" .. item.name
    pool[item.name] = scene:get(item.name)

    if cassette:get(key, false) then
      pool[item.name]:hide()
    else
      pool[item.name]:on_touch(function()
        if item.damage then overlay:dispatch(Widget.cursor, "damage") end
        if item.sound then soundmanager:play(item.sound) end
        pool.television.action:set("poltergeist")
        pool[item.name]:hide()
        cassette:set(key, true)
      end)
    end
  end

  pool.beelzebuuth = scene:get("beelzebuuth")
  pool.beelzebuuth.action:unset()

  -- local id = timermanager:set(6.66 * 6000, function()
  --   soundmanager:play("scream")
  --   pool.beelzebuuth.action:set("summon")
  -- end)
  -- table.insert(pool.timers, id)

  noise.init()

  noise.on_end(function ()
    write("I drown your holiness in the Acheron of my soul", 3, 3) -- 47
  end)
end

function scene.on_loop()
  noise.loop()
end

function scene.on_leave()
  noise.teardown()
  for _, id in ipairs(pool.timers) do
    timermanager:clear(id)
  end

  for k in pairs(pool) do pool[k] = nil end
end

function scene.on_touch()
  -- Depois de 3-5 touchs aparece o beelzebuuth

  pool.label:clear()

  if pool.timer then
    timermanager:clear(pool.timer)
    pool.timer = nil
  end
end

return scene
