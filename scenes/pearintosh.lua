local scene = {}

local scenemanager = engine:scenemanager()
local fontfactory = engine:fontfactory()
local overlay = engine:overlay()

local pool = {}

function scene.on_enter()
  pool.prelude = [[
MORNING STAR SOFTWARE 1986 (C)
BASIC V1.6.6
96128 BYTES FREE

]]

  pool.program = ""

  pool.label = overlay:create(WidgetType.label)
  local font = fontfactory:get("fixedsys")
  font.effect = FontEffect.cursor
  pool.label.font = font

  pool.label:set(pool.prelude .. pool.program)
end

function scene.on_loop(delta)
end

function scene.on_leave()
  pool = {}
end

function scene.on_text(text)
  pool.program = pool.program .. text
  pool.label:set(pool.prelude .. pool.program)
end

function scene.on_keypress(code)
  if code == KeyEvent.backspace and #pool.program > 0 then
    pool.program = pool.program:sub(1, -2)
    pool.label:set(pool.prelude .. pool.program)
    return
  end

  if code == KeyEvent.space then
    pool.program = pool.program .. " "
    pool.label:set(pool.prelude .. pool.program)
    return
  end

  if code == KeyEvent.enter then
    pool.program = pool.program .. "\n"
    pool.label:set(pool.prelude .. pool.program)
    return
  end
end

return scene
