local scene = {}

local pool = {}

local scenemanager = engine:scenemanager()
local cassete = engine:cassete()
local overlay = engine:overlay()
local timermanager = engine:timermanager()

function scene.on_enter()
  pool.counter = 0
  pool.timers = {}

  local objects = {
    {name = "bear", minimum = 2, maximum = 4, act = "blink"},
    {name = "clown", minimum = 6, maximum = 8, act = "blink"},
    {name = "robot", minimum = 3, maximum = 6, act = "shake"}
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
    {name = "crucifix", key = prefix .. "crucifix", damage = true},
    {name = "gijoe",    key = prefix .. "gijoe"},
    {name = "nintendo", key = prefix .. "nintendo"},
    {name = "playboy",  key = prefix .. "playboy"}
  }

  for _, i in ipairs(interactive) do
    pool[i.name] = scene:get(i.name)
    if cassete:get(i.key, false) then
      pool[i.name]:hide()
    else
      pool[i.name]:on_touch(function()
        if i.damage then
          overlay:dispatch(Widget.cursor, "damage")
        end

        pool[i.name]:hide()
        cassete:set(i.key, true)
      end)
    end
  end

  pool.beelzebuuth = scene:get("beelzebuuth")
end

function scene.on_loop(delta)
  pool.counter = pool.counter + 1

  if pool.counter % 666 == 0 then
    if pool.beelzebuuth then
      pool.beelzebuuth.action:set("summon")
    end
  end
end

function scene.on_leave(scenemanager, cassete)
  for _, id in ipairs(pool.timers) do
    timermanager:clear(id)
  end

  for key in pairs(pool) do
    pool[key] = nil
  end
end

return scene
