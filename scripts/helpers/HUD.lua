local function HUD(scene, options)
  local layout_name = options.layout
  local character_name = options.character
  local items = options.items

  local original_on_enter = scene.on_enter
  local original_on_motion = scene.on_motion
  local original_on_loop = scene.on_loop
  local original_on_leave = scene.on_leave

  scene.on_enter = function()
    if original_on_enter then
      original_on_enter()
    end

    local objects = {}
    for index = 1, #items do
      objects[index] = pool["HUD/" .. items[index]]
    end

    pool.inventory = Inventory.new(pool[layout_name], pool[character_name], objects)
  end

  scene.on_motion = function(x, y)
    pool.inventory.motion(x, y)

    if original_on_motion then
      original_on_motion(x, y)
    end
  end

  scene.on_loop = function(delta)
    if original_on_loop then
      original_on_loop(delta)
    end

    pool.inventory.loop(delta)
  end

  scene.on_leave = function()
    if original_on_leave then
      original_on_leave()
    end

    pool.inventory.teardown()
  end

  return scene
end

return HUD
