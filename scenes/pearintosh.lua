local scene = {}

local scenemanager = engine:scenemanager()
local fontfactory = engine:fontfactory()
local overlay = engine:overlay()

local pool = {}

function scene.on_enter()
  pool.program = ""
  pool.cursor_visible = true
  pool.last_blink = moment()

  pool.label = overlay:create(WidgetType.label)
  local font = fontfactory:get("fixedsys")
  pool.label.font = font

  pool.label:set("", 3, 3)
end

function scene.on_loop(delta)
  local now = moment()

  if now - pool.last_blink >= 400 then
    pool.cursor_visible = not pool.cursor_visible
    pool.last_blink = now

    local display_text = pool.program
    if pool.cursor_visible then
      display_text = display_text .. "'"
    end

    pool.label:set(display_text)
  end
end

function scene.on_leave()
  pool = {}
end

function scene.on_text(text)
  -- if not text:match("^[a-zA-Z0-9<>{}%[%]%(%)%+%-%.%*%&%^%%%$#@!~#@!]$") then
  --   return
  -- end

  pool.program = pool.program .. text
  pool.cursor_visible = true
  pool.last_blink = moment()

  pool.label:set(pool.program .. "'")
end

function scene.on_keypress(code)
  if code == KeyEvent.backspace and #pool.program > 0 then
    pool.program = pool.program:sub(1, -2)
    pool.cursor_visible = true
    pool.last_blink = moment()

    pool.label:set(pool.program .. "'")
    return
  end

  if code == KeyEvent.space then
    pool.program = pool.program .. " "
    pool.cursor_visible = true
    pool.last_blink = moment()

    pool.label:set(pool.program .. "'")
    return
  end
end

return scene
