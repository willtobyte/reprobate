local scene = {}

local scenemanager = engine:scenemanager()

local pool = {}

local function leave()
  scenemanager:set("mainmenu")
end

function scene.on_enter() end

function scene.on_touch()
  leave()
end

function scene.on_keypress()
  leave()
end

function scene.on_leave()
  for o in pairs(pool) do
    pool[o] = nil
  end
end

return scene
