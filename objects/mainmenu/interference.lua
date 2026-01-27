return {
  on_end = function()
    local stage = state.system.stage or "babyroom"
    print("interference on_end called, stage: " .. stage)
    scenemanager:set(stage)
  end,
}
