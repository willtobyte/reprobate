return {
  on_spawn = function()
    self:subscribe("misses", function(value)
      if value < 6 then
        return
      end

      pool.scream:play()
      self.action = "summon"
      self.misses = 0
    end)
  end,
}
