return {
  on_spawn = function()
    self.life = 5
  end,

  on_damage = function()
    if self.life <= 0 then
      return
    end

    self.life = self.life - 1
    self.action = tostring(self.life)

    if self.life == 0 then
      self.dead = true
    end
  end,
}
