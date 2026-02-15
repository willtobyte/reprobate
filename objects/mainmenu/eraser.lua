return {
  on_touch = function()
    cassette:clear()
    scenemanager:register("prelude")
    scenemanager:set("prelude")
  end,
}
