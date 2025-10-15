local M = {}

function M.n(name, delay)
  delay = delay or 300
  return function()
    timermanager:singleshot(delay, function()
      scenemanager:set(name)
    end)
  end
end

return M
