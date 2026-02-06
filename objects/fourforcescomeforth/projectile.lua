local mapping = {
  satan = { x = 1, y = -1 },
  belial = { x = 1, y = -1 },
  lucifer = { x = -1, y = 1 },
  leviathan = { x = -1, y = 1 },
}

return {
  on_spawn = function()
    self.velocity = { x = 50, y = 50 }
  end,

  on_collision = function(_, kind)
    if kind == "iconofhypocrisy" then
      pool.health.damage()
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

  on_screen_exit = function(direction)
    print("projectile exited screen: " .. direction)
  end,
}
