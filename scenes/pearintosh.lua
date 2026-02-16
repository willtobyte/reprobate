local scene = {}

local basic = require("interpreters/basic")

function scene.on_enter()
  state.system.stage = "pearintosh"

  transition({
    destroy = { "prelude", "mainmenu", "whobuilt" },
    register = { "highschool", "fourforcescomeforth" },
  })

  pool.label = overlay:label("retro")

  pool.prelude = [[
MORNING STAR SOFTWARE 1986 (C)
BASIC V1.6.6
49152 BYTES FREE

TYPE RUN TO BEGIN

]]
  pool.program = "10 "
  pool.cursor = {
    visible = true,
    timer = 0,
    interval = 0.3,
  }
  pool.typing = false
  pool.halted = false

  pool.dialup:on_end(function()
    local fn = jump.to("fourforcescomeforth")
    fn()
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
  if pool.label.glyphs:find(text, 1, true) then
    pool.program = pool.program .. text
    pool.typing = true
  end
end

function scene.on_keypress(code)
  if pool.halted then
    return
  end

  local effect = pool["key" .. math.random(2)]
  effect:play()

  if code == KeyEvent.backspace then
    pool.program = pool.program:sub(1, -2)
  elseif code == KeyEvent.enter then
    for line in pool.program:gmatch("[^\n]+") do
      local trimmed = line:match("^%s*(.-)%s*$")
      if trimmed:match("^%d+%s+RUN$") then
        pool.output = {}
        local errors = {}

        local function stdout(message)
          local achievements = {
            ["666"] = "ACH_IN_LEAGUE_WITH_SATAN", -- In League with Satan.
          }

          local id = achievements[string.upper(message)]
          if id then
            achievement:unlock(id)
          end

          pool.program = pool.program .. "\n" .. message

          pool.pentagram = message == "666"

          if pool.pentagram then
            pool.backcursor.visible = false
            pool.switch:on_touch(nil)
            pool.dialup:play()
            pool.program = pool.program
              .. "\n"
              .. [[

I invoke the Four Forces...

Satan, Adversary Eternal - grant me that which I desire.
Lucifer, Morning Star - grant me thy glare.
Belial, Sovereign Unbound - answer to thy name.
Leviathan, Serpent of the Abyss - serpent out of the deeps.

Four Forces come forth!

...]]
          end
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

    local line = 10
    for number in pool.program:gmatch("\n(%d+)[^\n]*") do
      number = tonumber(number)
      if number and number > line then
        last_line_number = number
      end
    end

    local next = line + 10

    if next > 200 then
      pool.program = pool.program .. "\nOUT OF MEMORY"
      pool.typing = true
      pool.halted = true
      return
    end

    pool.program = pool.program .. string.format("\n%d ", next)
    pool.typing = true
  end
end

function scene.on_leave()
  overlay:label(pool.label)
end

ticker.wrap(scene)
sentinel(scene, "pearintosh")

return scene
