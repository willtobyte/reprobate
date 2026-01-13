return {
  on_spawn = function()
    if not state.cabinetdoor then
      return
    end

    self.action = state.switch

    if state.switch == "on" then
      pool.light.action = "blinking"
    else
      pool.light.action = nil
    end
  end,

  on_touch = function()
    if not state.safe then
      return
    end

    pool.light.action = nil

    self.action = "off"
    state.switch = "off"
  end,
}
