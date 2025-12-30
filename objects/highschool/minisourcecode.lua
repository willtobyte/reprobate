return {
  on_touch = function()
    if pool.sourcecode.action ~= "default" then
      pool.sourcecode.action = "default"
    else
      pool.sourcecode.action = nil
    end
  end,
}
