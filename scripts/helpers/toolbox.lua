local M = {}

local unpack = table.unpack or unpack
local huge = math.huge
local next = next

local function dense(t)
  local n = #t
  for i = 1, n do
    if t[i] == nil then
      return nil
    end
  end
  return n
end

function M.any(t)
  local n = dense(t)
  if n then
    for i = 1, n do
      if t[i] then
        return true
      end
    end
    return false
  end
  for _, v in pairs(t) do
    if v then
      return true
    end
  end
  return false
end

function M.all(t)
  for _, v in pairs(t) do
    if not v then
      return false
    end
  end
  return true
end

return M
