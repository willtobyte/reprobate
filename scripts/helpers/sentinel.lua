local function sentinel(t, ongc)
  if type(t) ~= "table" then
    return nil
  end
  if type(ongc) ~= "function" then
    return nil
  end

  local np = rawget(_G, "newproxy")
  if np then
    local u = np(true)
    getmetatable(u).__gc = ongc
    rawset(t, "__sentinel", u)
    return u
  end

  local s = setmetatable({}, { __gc = ongc })
  rawset(t, "__sentinel", s)
  return s
end

return sentinel
