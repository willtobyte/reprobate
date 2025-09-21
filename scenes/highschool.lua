local scene = {}

local pool = {}

local timers = {}

local cassette = engine:cassette()
local scenemanager = engine:scenemanager()
local timermanager = engine:timermanager()

function scene.on_enter()
  scenemanager:destroy("mainmenu")
  scenemanager:destroy("whobuilt")
  scenemanager:destroy("livingroom")
  scenemanager:register("pearintosh")

  cassette:set("system/stage", "highschool")

  pool.binarymessage = scene:get("binarymessage", SceneType.object)
  -- pool.binarymessage:on_hover(function(self)
  --   self.action = "default"
  -- end)
  -- pool.binarymessage:on_unhover(function(self)
  --   self.action = nil
  -- end)
end

function scene.on_leave()
  for _, id in ipairs(timers) do
    timermanager:clear(id)
  end

  for name in pairs(pool) do
    pool[name] = nil
  end
end

sentinel(scene, "highschool")

return scene
