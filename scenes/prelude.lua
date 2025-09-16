local scene = {}

local sentinel = require("helpers/sentinel")

local pool = {}

local scenemanager = engine:scenemanager()

function scene.on_enter()
  scenemanager:register("mainmenu")
  scenemanager:register("whobuilt")

  pool.quarter = scene:get("quarter", SceneType.object)

  pool.quarter:on_hover(function(self)
    self.action = "hover"
  end)

  pool.quarter:on_unhover(function(self)
    self.action = "normal"
  end)

  pool.quarter:on_touch(function()
    scenemanager:set("mainmenu")
  end)

  pool.click = scene:get("click", SceneType.effect)
end

function scene.on_touch()
  pool.click:play()
end

function scene.on_loop() end

function scene.on_leave()
  for o in pairs(pool) do
    pool[o] = nil
  end
end

local function attach_finalizer(t, ongc)
  if type(t) ~= "table" or type(ongc) ~= "function" then
    return
  end
  local np = rawget(_G, "newproxy")
  if np then
    local u = np(true)
    getmetatable(u).__gc = ongc
    t.__sentinel = u
    return u
  end
  t.__sentinel = setmetatable({}, { __gc = ongc })
  return t.__sentinel
end

sentinel(scene, function()
  print("[GC] collected scene prelude")
end)

return scene
