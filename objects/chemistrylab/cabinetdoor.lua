return {
  on_spawn = function()
    if state.cabinetdoor then
      self.action = "open"
    end
  end,

  on_touch = function()
    if not state.safe then
      return
    end

    if state.cabinetdoor then
      return
    end

    self:on_touch(nil)

    state.cabinetdoor = true

    self.action = "open"
    pool.switch.action = "on"
    state.switch = "on"
  end,
}
