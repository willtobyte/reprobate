local scribe = {}

local INTERVAL = 0.08
local FADE_IN_DURATION = 1.0
local FADE_OUT_DURATION = 0.6

local label = overlay:label("rpgfont")
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
local effects = {}
local fade_effects = {}

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
	for k in pairs(effects) do
		effects[k] = nil
	end
	for k in pairs(fade_effects) do
		fade_effects[k] = nil
	end
	label.effect = nil
	label:clear()
end

function scribe.write(txt, px, py)
	assert(type(txt) == "string")
	assert(type(px) == "number")
	assert(type(py) == "number")
	text = txt
	index = 0
	accumulator = 0
	writing = true
	countdown = nil
	x, y = px, py
	label:set("", x, y)
end

function scribe.loop(delta)
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
		local alpha = fade_out_state.alpha
		local scale = fade_out_state.scale
		for i = 1, #text do
			local entry = fade_effects[i]
			if entry then
				entry.alpha = alpha
				entry.scale = scale
			else
				fade_effects[i] = { alpha = alpha, scale = scale }
			end
		end
		label.effect = fade_effects
		if moment() >= countdown then
			local cb = callback
			scribe.clear()
			if cb then
				return cb()
			end
		end
		return
	end

	local has_effects = false
	for i, s in pairs(states) do
		if s.alpha >= 255 then
			states[i] = nil
			tweens.scribe[i] = nil
			effects[i] = nil
		else
			local entry = effects[i]
			if entry then
				entry.alpha = s.alpha
			else
				effects[i] = { alpha = s.alpha }
			end
			has_effects = true
		end
	end
	if has_effects then
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
