local scene = {}

local overlay = engine:overlay()

local pool = {
  prelude = [[
MORNING STAR SOFTWARE 1986 (C)
BASIC V1.6.6
96128 BYTES FREE

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
  local font = engine:fontfactory():get("fixedsys")
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

  local text = pool.prelude .. pool.program .. (cursor.visible and "O" or "")
  pool.label:set(text)
end

function scene.on_text(text)
  pool.program = pool.program .. text
  pool.typing = true
end

function scene.on_keypress(code)
  if code == KeyEvent.backspace then
    pool.program = pool.program:sub(1, -2)
  elseif code == KeyEvent.space then
    pool.program = pool.program .. " "
  elseif code == KeyEvent.enter then
    pool.program = pool.program .. "\n"
  end
  pool.typing = true
end

function scene.on_leave()
  pool = {}
end

return scene
