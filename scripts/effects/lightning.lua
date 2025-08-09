local Lightning = {}
Lightning.__index = Lightning

local char, rep, random, floor = string.char, string.rep, math.random, math.floor
local ALPHA_DARK, ALPHA_CLEAR = 80, 0

function Lightning:new(width, height)
	local w, h = width or 480, height or 270
	local cache = {}
	for a = 0, 255 do
		cache[a] = char(0, 0, 0, a)
	end
	return setmetatable({
		canvas = engine:canvas(),
		w = w,
		h = h,
		dark_line = rep(cache[ALPHA_DARK], w),
		clear_line = rep(cache[ALPHA_CLEAR], w),
		active = false,
		sequence = {},
		seq_index = 1,
		state = "dark",
		state_end_time = 0,
	}, self)
end

function Lightning:trigger()
	local flashes = random(1, 3)
	local total_time = random(200, 2000) -- total em ms
	self.sequence = {}
	local remaining = total_time

	for i = 1, flashes do
		local max_for_this = floor(remaining / ((flashes - i + 1) * 2))
		if max_for_this < 30 then
			max_for_this = 30
		end
		local flash_len = random(30, max_for_this)
		local gap_len = (i < flashes) and flash_len or 0
		table.insert(self.sequence, { flash = flash_len, gap = gap_len })
		remaining = remaining - flash_len - gap_len
	end

	self.seq_index = 1
	self.active = true
	self.state = "flash"
	self.state_end_time = moment() + self.sequence[1].flash
	self.canvas.pixels = rep(self.clear_line, self.h) -- PISCAR AGORA
end

function Lightning:loop()
	if not self.active then
		self.canvas.pixels = rep(self.dark_line, self.h)
		return
	end

	local now = moment()
	local step = self.sequence[self.seq_index]

	if self.state == "flash" then
		if now >= self.state_end_time then
			if step.gap > 0 then
				self.state = "gap"
				self.state_end_time = now + step.gap
				self.canvas.pixels = rep(self.dark_line, self.h)
			else
				self.seq_index = self.seq_index + 1
				if not self.sequence[self.seq_index] then
					self.active = false
					self.canvas.pixels = rep(self.dark_line, self.h)
					return
				end
				self.state = "flash"
				self.state_end_time = now + self.sequence[self.seq_index].flash
				self.canvas.pixels = rep(self.clear_line, self.h)
			end
		else
			self.canvas.pixels = rep(self.clear_line, self.h)
		end
	elseif self.state == "gap" then
		if now >= self.state_end_time then
			self.seq_index = self.seq_index + 1
			if not self.sequence[self.seq_index] then
				self.active = false
				self.canvas.pixels = rep(self.dark_line, self.h)
				return
			end
			self.state = "flash"
			self.state_end_time = now + self.sequence[self.seq_index].flash
			self.canvas.pixels = rep(self.clear_line, self.h)
		else
			self.canvas.pixels = rep(self.dark_line, self.h)
		end
	end
end

function Lightning:teardown()
	self.active = false
	self.canvas.pixels = rep(self.dark_line, self.h)
end

return Lightning:new()
