local M = {}

function M.to(name, delay)
  assert(type(name) == "string" and #name > 0, "scene name must be a non-empty string")
  assert(delay == nil or (type(delay) == "number" and delay >= 0), "delay must be a non-negative number")

  delay = delay or 100
  return function()
    timermanager:singleshot(delay, function()
      scenemanager:set(name)
    end)
  end
end

return M
