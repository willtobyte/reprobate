local scribe = {}

local INTERVAL = 0.08
local FADE_IN_DURATION = 1.0
local FADE_OUT_DURATION = 0.6

local label = nil
local text = ""
local index = 0
local accumulator = 0
local writing = false
local finish_delay = 0
local countdown = nil
local callback = nil
local x, y = 0, 0
local states = {}
local fading_out = false
local fade_out_state = nil

local function initialize()
	if not label then
		label = overlay:create(WidgetType.label)
		local font = fontfactory:get("rpgfont")
		label.font = font
	end
end

function scribe.on_finish(timeout, cb)
	assert(type(timeout) == "number")
	assert(type(cb) == "function")
	finish_delay = timeout
	callback = cb
end

function scribe.clear()
	index = 0
	text = ""
	accumulator = 0
	writing = false
	countdown = nil
	callback = nil
	fading_out = false
	fade_out_state = nil
	tweens.scribe.fade_out = nil
	for k in pairs(states) do
		tweens.scribe[k] = nil
		states[k] = nil
	end
	if label then
		label.effect = nil
		label:clear()
	end
end

function scribe.write(txt, px, py)
	assert(type(txt) == "string")
	assert(type(px) == "number")
	assert(type(py) == "number")
	initialize()
	if not label then
		return
	end
	text = txt
	index = 0
	accumulator = 0
	writing = true
	countdown = nil
	x, y = px, py
	label:set("", x, y)
end

function scribe.loop(delta)
	if not label then
		return
	end

	if writing then
		accumulator = accumulator + delta
		while accumulator >= INTERVAL do
			accumulator = accumulator - INTERVAL
			index = index + 1
			local substr = text:sub(1, index)
			label:set(substr, x, y)
			states[index] = { alpha = 0 }
			tweens.scribe[index] = tween.new(FADE_IN_DURATION, states[index], { alpha = 255 }, "outQuad")
			if index >= #text then
				writing = false
				countdown = moment() + finish_delay
				break
			end
		end
	end

	if fading_out then
		local effects = {}
		for i = 1, #text do
			effects[i] = { alpha = fade_out_state.alpha, scale = fade_out_state.scale }
		end
		label.effect = effects
		if moment() >= countdown then
			local cb = callback
			scribe.clear()
			if cb then
				return cb()
			end
		end
		return
	end

	local effects = {}
	local completed = {}
	for i, s in pairs(states) do
		if s.alpha >= 255 then
			completed[#completed + 1] = i
		else
			effects[i] = { alpha = s.alpha }
		end
	end
	for j = 1, #completed do
		local i = completed[j]
		states[i] = nil
		tweens.scribe[i] = nil
	end
	if next(effects) then
		label.effect = effects
	end

	if not writing and countdown then
		if moment() >= countdown then
			fading_out = true
			fade_out_state = { alpha = 255, scale = 1.0 }
			tweens.scribe.fade_out = tween.new(FADE_OUT_DURATION, fade_out_state, { alpha = 0, scale = 0.0 }, "linear")
			countdown = moment() + (FADE_OUT_DURATION * 1000)
		end
	end
end

function scribe.say(message, px, py, ttl)
	scribe.clear()
	scribe.write(message, px or 3, py or 3)
	scribe.on_finish(ttl or 6000, function()
		scribe.clear()
	end)
end

return scribe
