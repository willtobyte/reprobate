local scene = {}

local pool = {}

local scenemanager = engine:scenemanager()
local cassette = engine:cassette()
local overlay = engine:overlay()
local timermanager = engine:timermanager()
local soundmanager = engine:soundmanager()

function scene.on_enter()
  pool.timers = {}

  local objects = {
    { name = "bear",  minimum = 2, maximum = 4, act = "blink" },
    { name = "clown", minimum = 6, maximum = 8, act = "blink" },
    { name = "robot", minimum = 3, maximum = 6, act = "shake" },
  }

  for _, o in ipairs(objects) do
    pool[o.name] = scene:get(o.name)
    local delay = math.random(o.minimum, o.maximum) * 1000
    local id = timermanager:set(delay, function()
      pool[o.name].action:set(o.act)
    end)

    table.insert(pool.timers, id)
  end

  local prefix = "babyroom/"
  local interactive = {
    { name = "crucifix", key = prefix .. "crucifix", sound = "wind", damage = true },
    { name = "gijoe",    key = prefix .. "gijoe", sound = "door" },
    { name = "nintendo", key = prefix .. "nintendo", sound = "metal" },
    { name = "playboy",  key = prefix .. "playboy", sound = "gore" }
  }

  pool.television = scene:get("television")

  for _, i in ipairs(interactive) do
    pool[i.name] = scene:get(i.name)
    if cassette:get(i.key, false) then
      pool[i.name]:hide()
    else
      pool[i.name]:on_touch(function()
        if i.damage then
          overlay:dispatch(Widget.cursor, "damage")
        end

        if i.sound then
          soundmanager:play(i.sound)
        end

        pool.television.action:set("poltergeist")
        pool[i.name]:hide()
        cassette:set(i.key, true)
      end)
    end
  end

  pool.beelzebuuth = scene:get("beelzebuuth")
  local id = timermanager:set(666000, function()
    pool.beelzebuuth.action:set("summon")
  end)

  table.insert(pool.timers, id)
end

function scene.on_loop()
end

function scene.on_leave()
  for _, id in ipairs(pool.timers) do
    timermanager:clear(id)
  end

  for key in pairs(pool) do
    pool[key] = nil
  end
end

return scene
