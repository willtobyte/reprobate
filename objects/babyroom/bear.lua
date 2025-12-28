return {
  on_begin = function() end,

  on_loop = function(delta) end,

  on_end = function() end,

  on_collision = function() end,

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
