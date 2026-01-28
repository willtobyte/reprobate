return {
  on_end = function()
    local stage = state.system.stage or "babyroom"
    scenemanager:set(stage)
  end,
}
