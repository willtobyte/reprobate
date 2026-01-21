local PHASE_INACTIVE = 0
local PHASE_BRIGHT = 1
local PHASE_DARK = 2
local ACTION_DEFAULT = "default"
local RANDOM_POOL_SIZE = 32

local moment = moment
local math_random = math.random

local darker = nil
local thunder = nil

local delay_pool = {}
local count_pool = {}
local pool_index = 0

local active = false
local next_at = 0
local count = 0
local total = 0
local phase = PHASE_INACTIVE

local function next_delay()
  pool_index = pool_index % RANDOM_POOL_SIZE + 1
  return delay_pool[pool_index]
end

local function next_count()
  pool_index = pool_index % RANDOM_POOL_SIZE + 1
  return count_pool[pool_index]
end

local function trigger()
  if active then
    return
  end
  active = true
  count = 0
  total = next_count()
  phase = PHASE_BRIGHT
  darker.action = nil
  next_at = moment() + next_delay()
end

return {
  on_spawn = function()
    darker = pool.darker
    thunder = pool.thunder

    for index = 1, RANDOM_POOL_SIZE do
      delay_pool[index] = math_random(20, 30)
      count_pool[index] = math_random(3, 4)
    end

    ticker.every(math_random(3, 6) * 10, function()
      self.action = "lightning"
      trigger()
      thunder:play()
    end)
  end,

  on_loop = function()
    if phase == PHASE_INACTIVE then
      return
    end

    if moment() < next_at then
      return
    end

    if phase == PHASE_BRIGHT then
      count = count + 1
      darker.action = ACTION_DEFAULT
      if count >= total then
        active = false
        phase = PHASE_INACTIVE
        return
      end
      phase = PHASE_DARK
      next_at = moment() + next_delay()
      return
    end

    darker.action = nil
    phase = PHASE_BRIGHT
    next_at = moment() + next_delay()
  end,

  on_touch = function()
    say("You cannot escape your own mind.", 3, 3, 3000)
  end,
}
