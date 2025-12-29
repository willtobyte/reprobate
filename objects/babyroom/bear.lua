return {
  on_begin = function() end,

  on_end = function() end,

  on_collision_end = function() end,

  on_mail = function(from, body) end,

  on_damage = function(amount)
    return tostring(amount)
  end,

  on_loop = function()
    emit.hello("world")
  end,
}
