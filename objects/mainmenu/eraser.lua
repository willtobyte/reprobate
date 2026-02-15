return {
  on_touch = function()
    state.clear()
    scenemanager:register("prelude")
    scenemanager:set("prelude")
  end,
}
