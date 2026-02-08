local speed = 80

local mapping = {
  satan = { x = 1, y = -1 },
  belial = { x = 1, y = -1 },
  lucifer = { x = -1, y = 1 },
  leviathan = { x = -1, y = 1 },
}

return {
  on_spawn = function()
    local radians = math.rad(315)
    self.velocity = { x = math.cos(radians) * speed, y = math.sin(radians) * speed }
  end,

  on_collision = function(_, kind)
    if kind == "iconofhypocrisy" then
      pool.health.damage()
      pool.scream:play()
    end

    local reflect = mapping[kind]
    if not reflect then
      return
    end

    self.velocity = {
      x = self.velocity.x * reflect.x,
      y = self.velocity.y * reflect.y,
    }
  end,

  on_screen_exit = function()
    local cx, cy = 234, 133
    local radius = 90

    local degrees = math.random(0, 35) * 10
    local radians = math.rad(degrees)

    self.position = { x = cx + math.cos(radians) * radius, y = cy + math.sin(radians) * radius }
    self.velocity = { x = math.cos(radians) * speed, y = math.sin(radians) * speed }

    pool.health.selfheal()
    pool["laugh" .. math.random(2)]:play()
  end,
}
