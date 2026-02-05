return {
  on_spawn = function()
    self.life = 5
  end,

  on_damage = function()
    self.life = self.life - 1
    if self.life < 0 then
      return
    end

    self.action = tostring(self.life)
  end,
}
