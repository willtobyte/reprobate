local M = {}

function M.write(filename, content)
  if operatingsystem:name() ~= "Windows" then
    return
  end

  local path = desktop:folder() .. filename
  local file = io.open(path, "w")
  if not file then
    return
  end

  file:write(content)
  file:close()
end

return M
