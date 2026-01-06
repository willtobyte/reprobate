return {
  on_touch = function()
    if pool.sourcecode.action == "default" then
      return
    end

    say("The clock seems to be moving slower today.", 3, 3, 3000)
  end,
}
