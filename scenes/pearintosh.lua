local basic = require("interpreter/basic")

local scene = {}

local overlay = engine:overlay()

local pool = {
  prelude = [[
MORNING STAR SOFTWARE 1986 (C)
BASIC V1.6.6
49152 BYTES FREE

RUN TO EXECUTE

]],
  program = "",
  cursor = {
    visible = true,
    timer = 0,
    interval = 0.3
  },
  typing = false
}

function scene.on_enter()
  pool.font = engine:fontfactory():get("retro")
  pool.label = overlay:create(WidgetType.label)
  pool.label.font = pool.font

  local switch = scene:get("switch", SceneType.object)
  switch:on_touch(function()
    pool.program = ""
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
  pool.label:set(text, 105, 20)
end

function scene.on_text(text)
  if pool.font.glyphs:find(text, 1, true) then
    pool.program = pool.program .. text
    pool.typing = true
  end
end

function scene.on_keypress(code)
  if code == KeyEvent.backspace then
    pool.program = pool.program:sub(1, -2)
  elseif code == KeyEvent.space then
    pool.program = pool.program .. " "
  elseif code == KeyEvent.enter then
    pool.program = pool.program .. "\n"

    if pool.program:match("\nRUN%s*\n$") or pool.program:match("^RUN%s*\n$") then
      pool.output = {}

      local function stdout(message)
        pool.program = pool.program .. "\n" .. message .. "\n"
      end

      local function stderr(message)
        pool.program = pool.program .. "\n" .. message .. "\n"
      end

      local ok, err = pcall(function()
        basic(pool.program, stdout, stderr)
      end)

      if not ok then
        stderr(err)
      end
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
