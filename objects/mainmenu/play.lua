return {
  on_touch = function()
    pool.theme:stop()
    pool.play:on_touch(nil)
    pool.whobuilt:on_touch(nil)
    pool.interference.action = "default"
    pool.noise:play(true)
  end,
}
