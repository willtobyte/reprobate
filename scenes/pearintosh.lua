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

  pool.cursor = {
    visible = true,
    timer = moment(),
    blink_interval = 400
  }

  pool.label = overlay:create(WidgetType.label)
  local font = fontfactory:get("fixedsys")
  pool.label.font = font

  --pool.label:set(pool.prelude .. pool.program)
end

function scene.on_loop(delta)
  local now = moment()
  if now - pool.cursor.timer >= pool.cursor.blink_interval then
    pool.cursor.visible = not pool.cursor.visible
    pool.cursor.timer = now
  end

  local display_text = pool.prelude .. pool.program
  if pool.cursor.visible then
    display_text = display_text .. "O"
  end

  pool.label:set(display_text)
end

function scene.on_leave()
  pool = {}
end

function scene.on_text(text)
  pool.program = pool.program .. text
end

function scene.on_keypress(code)
  if code == KeyEvent.backspace and #pool.program > 0 then
    pool.program = pool.program:sub(1, -2)
    return
  end

  if code == KeyEvent.space then
    pool.program = pool.program .. " "
    return
  end

  if code == KeyEvent.enter then
    pool.program = pool.program .. "\n"
    return
  end
end

return scene
