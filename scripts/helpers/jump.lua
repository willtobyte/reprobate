local M = {}

function M.to(name, delay)
  delay = delay or 100
  return function()
    timermanager:singleshot(delay, function()
      scenemanager:sql(name)
    end)
  end
end

return M
