return {
  on_touch = function()
    pool.theme:stop()
    pool.play:on_touch(nil)
    pool.credits:on_touch(nil)

    pool.interference.action = "default"
    pool.noise:play(true)

    local stage = state.system.stage or "babyroom"

    local fn = jump.to(stage, 1100)
    fn()
  end,
}
