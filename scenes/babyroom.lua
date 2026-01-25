local scene = {}

local prank = require("helpers/prank")

local items = { "crucifix", "gijoe", "nintendo", "playboy" }

local function verify()
  for _, name in ipairs(items) do
    if not state[name] then
      return
    end
  end

  state.system.stage = "livingroom"

  pool.door.action = "default"

  ticker.after(30, function()
    pool.doorsound:play()
    pool.door:on_touch(jump.to("livingroom"))
  end)
end

local held = nil

function scene.on_enter()
  state.system.stage = "babyroom"

  transition({
    destroy = { "mainmenu", "whobuilt" },
    register = { "livingroom" },
  })

  -- TODO
  -- prank.write("We Have A Connection.txt", "")

  held = slot.collected(function()
    pool.television.animate()
    verify()
  end)

  scribe.say("I drown your divinity in the acheron of my soul.", 3, 3, 12000)
end

function scene.on_touch()
  pool.beelzebuuth.misses = (pool.beelzebuuth.misses or 0) + 1
end

function scene.on_loop(delta)
  scribe.loop(delta)

  tweens.loop(delta, function(type, name, t)
    if t.subject and type == "disappear" then
      t.subject.visible = false
    end
  end)
end

function scene.on_leave()
  disconnect(held)
  scribe.clear()
  tweens.teardown()
end

HUD(scene, {
  layout = "layout",
  character = "boy",
  items = items,
})

ticker.wrap(scene)
sentinel(scene, "babyroom")

return scene
