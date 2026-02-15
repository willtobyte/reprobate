local clickables = { "play", "whobuilt", "settings", "help" }

return {
  on_appear = function()
    for _, name in ipairs(clickables) do
      pool[name]:on_touch(nil)
    end
  end,

  on_touch = function()
    self.action = nil
  end,

  on_disappear = function()
    for _, name in ipairs(clickables) do
      pool[name]:on_touch(pool[name].touch)
    end
  end,
}
