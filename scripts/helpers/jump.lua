local M = {}

function M.to(name, delay)
  delay = delay or 200
  return function()
    timermanager:singleshot(delay, function()
      scenemanager:set(name)
    end)
  end
end

return M
