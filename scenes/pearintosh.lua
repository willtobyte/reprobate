local basic = require("interpreter/basic")

local scene = {}
local overlay = engine:overlay()

local pool = {
  prelude = [[
MORNING STAR SOFTWARE 1986 (C)
BASIC V1.6.6
49152 BYTES FREE

RUN TO EXECUTE, EXIT TO QUIT

]],
  program = "10 ",
  cursor = {
    visible = true,
    timer = 0,
    interval = 0.3,
  },
  typing = false,
  halted = false,
}

function scene.on_enter()
  pool.font = engine:fontfactory():get("retro")
  pool.label = overlay:create(WidgetType.label)
  pool.label.font = pool.font

  pool.effects = {}
  pool.effects.key1 = scene:get("key1", SceneType.effect)
  pool.effects.key2 = scene:get("key2", SceneType.effect)

  pool.music = scene:get("music", SceneType.effect)
  pool.music:play(true)

  local switch = scene:get("switch", SceneType.object)
  switch:on_touch(function()
    pool.program = "10 "
    pool.halted = false
  end)
end

function scene.on_loop(delta)
  local cursor = pool.cursor

  if pool.typing then
    cursor.visible = false
    cursor.timer = 0
    pool.typing = false
  else
    cursor.timer = cursor.timer + delta
    if cursor.timer >= cursor.interval then
      cursor.visible = not cursor.visible
      cursor.timer = 0
    end
  end

  local text = pool.prelude .. pool.program .. (cursor.visible and "_" or "")
  pool.label:set(text, 105, 18)
end

function scene.on_text(text)
  if pool.halted then
    return
  end

  text = string.upper(text)
  if pool.font.glyphs:find(text, 1, true) then
    pool.program = pool.program .. text
    pool.typing = true
  end
end

function scene.on_keypress(code)
  if pool.halted then
    return
  end

  (pool.effects)["key" .. math.random(2)]:play()

  if code == KeyEvent.backspace then
    pool.program = pool.program:sub(1, -2)
  elseif code == KeyEvent.enter then
    for line in pool.program:gmatch("[^\n]+") do
      local trimmed = line:match("^%s*(.-)%s*$")
      if trimmed:match("^%d+%s+RUN$") then
        pool.output = {}
        local errors = {}

        local function stdout(message)
          -- local achievements = {
          -- 	["666"] = "NEW_ACHIEVEMENT_2_2",
          -- 	["SATAN"] = "NEW_ACHIEVEMENT_2_3",
          -- 	["3"] = "NEW_ACHIEVEMENT_2_4",
          -- 	["4"] = "NEW_ACHIEVEMENT_2_4",
          -- }

          -- local id = achievements[message]
          -- if id then
          -- 	achievement:unlock(id)
          -- end

          pool.program = pool.program .. "\n" .. message
        end

        local function stderr(message)
          table.insert(errors, message)
          pool.halted = true
        end

        local ok, err = pcall(function()
          basic(pool.program, stdout, stderr)
        end)

        if not ok then
          table.insert(errors, err)
          pool.halted = true
        end

        if pool.halted then
          pool.program = pool.program .. "\n"

          for _, message in ipairs(errors) do
            pool.program = pool.program .. "\n" .. message
          end
          pool.program = pool.program .. "\nPLEASE RESTART"
        end

        pool.typing = true
        return
      end
    end

    local last_line_number = 10
    for number in pool.program:gmatch("\n(%d+)[^\n]*") do
      number = tonumber(number)
      if number and number > last_line_number then
        last_line_number = number
      end
    end

    local next_line_number = last_line_number + 10

    if next_line_number > 200 then
      pool.program = pool.program .. "\nOUT OF MEMORY"
      pool.typing = true
      pool.halted = true
      return
    end

    pool.program = pool.program .. string.format("\n%d ", next_line_number)
    pool.typing = true
  end
end

function scene.on_leave()
  for o in pairs(pool) do
    pool[o] = nil
  end
end

return scene
