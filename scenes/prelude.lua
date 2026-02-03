local scene = {}

function scene.on_enter()
  transition({ register = { "mainmenu", "whobuilt" } })
  pool.clicks = 0

  print("Persona: " .. user:persona())

  local buddies = user:buddies()
  for i = 1, #buddies do
    local buddy = buddies[i]
    print("Buddy ID: " .. tostring(buddy.id) .. ", Name: " .. buddy.name)
  end
end

function scene.on_touch()
  pool.click:play()

  pool.clicks = pool.clicks + 1
  if pool.clicks >= 10 then
    achievement:unlock("ACH_CLICK_FOREHEAD") -- How about trying to click with your forehead?
  end
end

sentinel(scene, "prelude")

return scene
