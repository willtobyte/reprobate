local module = {}
module.__index = module

function module.construct(scenemanager, entitymanager)
  local self = setmetatable({}, module)
  self.entities = {}
  self.scenemanager = scenemanager
  self.scenemanager:set("1")
  self.entitymanager = entitymanager
  self.entities["candle 1"] = self.entitymanager:spawn("player")
  return self
end

function module:loop(delta)
end

function module:destroy()
end

return module
