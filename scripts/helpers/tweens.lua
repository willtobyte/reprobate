local tweens = {}

setmetatable(tweens, {
  __index = function(t, key)
    if key == "loop" or key == "teardown" then
      return rawget(tweens, key)
    end
    local group = {}
    rawset(t, key, group)
    return group
  end,
})

function tweens.loop(delta, callback)
  for type, group in pairs(tweens) do
    if type ~= "loop" and type ~= "teardown" then
      for name, t in pairs(group) do
        if t:update(delta) then
          if callback then
            callback(type, name, t)
          end
          group[name] = nil
        end
      end
    end
  end
end

function tweens.teardown()
  for k in pairs(tweens) do
    if k ~= "loop" and k ~= "teardown" then
      tweens[k] = nil
    end
  end
end

return tweens
