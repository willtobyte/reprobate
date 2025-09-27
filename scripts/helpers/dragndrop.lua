local M = {}

local reference = nil

function M.set(object)
  reference = object
end

function M.unset()
  reference = nil
end

function M.motion(x, y)
  if not reference then
    return
  end
end

function M.loop(delta)
  if not reference then
    return
  end
end

function M.drop(target) end

function M.teardown()
  reference = nil
end

return M
