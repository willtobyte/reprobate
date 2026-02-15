local clickables = { "play", "whobuilt", "settings", "help" }

return {
  on_appear = function()
    for _, name in ipairs(clickables) do
      pool[name]:on_touch(nil)
    end

    pool.eraser.action = "default"
  end,

  on_touch = function()
    self.action = nil
  end,

  on_disappear = function()
    for _, name in ipairs(clickables) do
      pool[name]:on_touch(pool[name].touch)
    end

    pool.eraser.action = nil
  end,
}
