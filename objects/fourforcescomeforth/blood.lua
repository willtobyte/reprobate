return {
  on_spawn = function()
    print("On init")
    self.life = 5
  end,

  on_damage = function()
    print("On damage")

    self.life = self.life - 1
    if self.life < 0 then
      return
    end

    self.action = tostring(self.life)
  end,
}
