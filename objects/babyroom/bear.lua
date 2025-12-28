return {
  on_begin = function() end,

  on_end = function() end,

  on_loop = function()
    print(">>> " .. self.kind .. " " .. tostring(pool.playboy.kind))
  end,

  on_collision_end = function() end,

  on_mail = function(self, sender, body)
    print(
      "Self "
        .. tostring(self.id)
        .. " Sender "
        .. tostring(sender.id)
        .. " "
        .. tostring(sender.kind)
        .. " Body "
        .. body
    )
  end,
}
