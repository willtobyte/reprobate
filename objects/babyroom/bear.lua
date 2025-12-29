return {
  on_begin = function() end,

  on_end = function() end,

  on_collision_end = function() end,

  on_mail = function(from, body)
    print("From " .. tostring(from) .. " Body " .. body)
  end,

  on_rodrigo = function(arg1, arg2)
    -- print("On Rodrigo " .. tostring(arg1) .. " " .. tostring(arg2))
  end,
}
