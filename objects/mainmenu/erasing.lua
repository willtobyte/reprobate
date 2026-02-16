return {
  on_end = function()
    scenemanager:register("prelude")
    scenemanager:set("prelude")

    self.action = nil
  end,
}
