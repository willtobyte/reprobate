local scene = {}

local scenemanager = engine:scenemanager()
local fontfactory = engine:fontfactory()
local overlay = engine:overlay()

local pool = {}

function scene.on_enter()
  pool.program = ""

  pool.label = overlay:create(WidgetType.label)
  local font = fontfactory:get("fixedsys")
  pool.label.font = font

  pool.label:set("", 3, 3)
end

function scene.on_leave()
  pool = {}
end

function scene.on_text(text)
  print("text " .. string.byte(text) .. " program " .. pool.program)

  if not text:match("^[a-zA-Z0-9<>{}%[%]%(%)%+%-%.%*%&%^%%%$#@!~#@!]$") then
    return
  end

  pool.program = pool.program .. text

  pool.label:set(pool.program)
end

function scene.on_keypress(code)
  if code == KeyEvent.backspace and #pool.program > 0 then
    pool.program = pool.program:sub(1, -2)

    print("Backspace")

    pool.label:set("")
    pool.label:set(pool.program)
    end
end

return scene
