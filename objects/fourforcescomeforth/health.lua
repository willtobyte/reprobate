return {
  on_spawn = function()
    self.life = 5

    self:subscribe("life", function(value)
      self.action = tostring(value)
    end)
  end,

  on_selfheal = function()
    self.life = 5
  end,

  on_damage = function()
    if self.life <= 0 then
      return
    end

    self.life = self.life - 1

    pool.iconofhypocrisy.action = "damage"

    if self.life == 0 then
      self.dead = true
    end
  end,
}
