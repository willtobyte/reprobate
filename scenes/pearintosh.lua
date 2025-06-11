local basic = require("interpreter/basic")

local scene = {}

local overlay = engine:overlay()

local pool = {
  prelude = [[
MORNING STAR SOFTWARE 1986 (C)
BASIC V1.6.6
49152 BYTES FREE

CODE TRANSMITTED THROUGH A CRT SEANCE
ANOMALIES MAY OCCUR
ERR 0x02: FLOPPY READ FAILURE SECTOR 13h
]],
  program = "",
  cursor = {
    visible = true,
    timer = 0,
    interval = 0.5
  },
  typing = false
}

function scene.on_enter()
  local font = engine:fontfactory():get("retro")
  pool.label = overlay:create(WidgetType.label)
  pool.label.font = font
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
  pool.label:set(text, 105, 20)
end

function scene.on_text(text)
  pool.program = pool.program .. text
  pool.typing = true
end

function scene.on_keypress(code)
  print(code)
  if code == KeyEvent.backspace then
    pool.program = pool.program:sub(1, -2)
  elseif code == KeyEvent.space then
    pool.program = pool.program .. " "
  elseif code == KeyEvent.enter then
    print("enter")
    pool.program = pool.program .. "\n"

    if pool.program:match("\nRUN%s*\n$") or pool.program:match("^RUN%s*\n$") then
      pool.output = {}
      local program = [[
10 LET N = 6
20 FOR I = 1 TO 3
30 PRINT N
40 NEXT I
50 GOTO 70
60 PRINT "THIS LINE WILL BE SKIPPED"
70 PRINT "HELLO"
      ]]

      local function stdout(message)
        print(message)
        -- table.insert(pool.output, message:upper() .. "\n")
      end

      local function stderr(message)
        print(message)
        -- table.insert(pool.output, "ERROR: " .. message:upper() .. "\n")
      end

      local ok, err = pcall(function()
        basic(program, stdout, stderr)
      end)

      if not ok then
        stderr(err)
      end

      pool.program = ""
    end
  pool.typing = true
  end
end

function scene.on_leave()
  for o in pairs(pool) do
    pool[o] = nil
  end
end

return scene
