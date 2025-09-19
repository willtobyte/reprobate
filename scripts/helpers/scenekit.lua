local scenemanager = engine:scenemanager()

local function make(name, spec)
  spec = spec or {}

  local scene = {}

  local pool = { timers = {} }

  function scene.on_enter()
    local d = spec.destroy
    if d then
      for i = 1, #d do
        scenemanager:destroy(d[i])
      end
    end

    local r = spec.register
    if r then
      for i = 1, #r do
        scenemanager:register(r[i])
      end
    end

    -- cassette:set("system/stage", name)

    local on_enter = spec.on_enter
    if on_enter then
      on_enter(scene, pool)
    end
  end

  function scene.on_leave()
    for _, id in ipairs(pool.timers) do
      timermanager:clear(id)
    end

    for n in pairs(pool) do
      pool[n] = nil
    end
  end

  sentinel(scene, name)

  return scene
end

return { make = make }
