return {
  on_touch = function()
    achievement:unlock("ACH_BLESSED_BY_THE_GOAT")
    pool.goat:play()
  end,
}
