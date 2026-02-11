local scribe = {}

local INTERVAL = 0.08
local FADE_IN_DURATION = 1.0
local FADE_OUT_DURATION = 0.6

local label = overlay:label("rpgfont")

local NILABLE_KEYS = { "countdown", "callback", "fade_out_state" }

local DEFAULTS = {
  text = "",
  index = 0,
  accumulator = 0,
  writing = false,
  finish_delay = 0,
  x = 0,
  y = 0,
  fading_out = false,
}

local state = {}
local states = {}
local effects = {}
local fade_effects = {}

local function clear_table(target)
  for key in pairs(target) do
    target[key] = nil
  end
end

local function reset_state()
  for key, value in pairs(DEFAULTS) do
    state[key] = value
  end
  for _, key in ipairs(NILABLE_KEYS) do
    state[key] = nil
  end
end

local function ensure_entry(entries, position, values)
  local entry = entries[position]
  if entry then
    for key, value in pairs(values) do
      entry[key] = value
    end
  else
    entries[position] = values
  end
end

reset_state()

function scribe.on_finish(timeout, callback)
  assert(type(timeout) == "number")
  assert(type(callback) == "function")
  state.finish_delay = timeout
  state.callback = callback
end

function scribe.clear()
  reset_state()
  tweens.scribe.fade_out = nil
  for key in pairs(states) do
    tweens.scribe[key] = nil
  end
  clear_table(states)
  clear_table(effects)
  clear_table(fade_effects)
  label.effect = nil
  label:clear()
end

function scribe.write(text, px, py)
  assert(type(text) == "string")
  assert(type(px) == "number")
  assert(type(py) == "number")
  state.text = text
  state.index = 0
  state.accumulator = 0
  state.writing = true
  state.countdown = nil
  state.x, state.y = px, py
  label:set("", px, py)
end

local function step_write(delta)
  if not state.writing then
    return
  end
  state.accumulator = state.accumulator + delta
  while state.accumulator >= INTERVAL do
    state.accumulator = state.accumulator - INTERVAL
    state.index = state.index + 1
    label:set(state.text:sub(1, state.index), state.x, state.y)
    states[state.index] = { alpha = 0 }
    tweens.scribe[state.index] = tween.new(FADE_IN_DURATION, states[state.index], { alpha = 255 }, "outQuad")
    if state.index >= #state.text then
      state.writing = false
      state.countdown = moment() + state.finish_delay
      break
    end
  end
end

local function step_fade_out()
  if not state.fading_out then
    return false
  end
  local alpha = state.fade_out_state.alpha
  local scale = state.fade_out_state.scale
  for position = 1, #state.text do
    ensure_entry(fade_effects, position, { alpha = alpha, scale = scale })
  end
  label.effect = fade_effects
  if moment() >= state.countdown then
    local callback = state.callback
    scribe.clear()
    if callback then
      callback()
    end
  end
  return true
end

local function step_effects()
  local has_effects = false
  for position, entry in pairs(states) do
    if entry.alpha >= 255 then
      states[position] = nil
      tweens.scribe[position] = nil
      effects[position] = nil
    else
      ensure_entry(effects, position, { alpha = entry.alpha })
      has_effects = true
    end
  end
  if has_effects then
    label.effect = effects
  end
end

local function step_countdown()
  if state.writing or not state.countdown then
    return
  end
  if moment() >= state.countdown then
    state.fading_out = true
    state.fade_out_state = { alpha = 255, scale = 1.0 }
    tweens.scribe.fade_out = tween.new(FADE_OUT_DURATION, state.fade_out_state, { alpha = 0, scale = 0.0 }, "linear")
    state.countdown = moment() + (FADE_OUT_DURATION * 1000)
  end
end

function scribe.loop(delta)
  step_write(delta)
  if step_fade_out() then
    return
  end
  step_effects()
  step_countdown()
end

function scribe.say(message, px, py, ttl)
  scribe.clear()
  scribe.write(message, px or 3, py or 3)
  scribe.on_finish(ttl or 6000, function()
    scribe.clear()
  end)
end

return scribe
