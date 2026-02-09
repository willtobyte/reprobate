local PHASE_INACTIVE = 0
local PHASE_BRIGHT = 1
local PHASE_DARK = 2
local RANDOM_POOL_SIZE = 32

local delay_pool = {}
local count_pool = {}
local pool_index = 0

local active = false
local next_at = 0
local count = 0
local total = 0
local phase = PHASE_INACTIVE

local function next_from(t)
  pool_index = pool_index % RANDOM_POOL_SIZE + 1
  return t[pool_index]
end

local function trigger()
  if active then
    return
  end
  active = true
  count = 0
  total = next_from(count_pool)
  phase = PHASE_BRIGHT
  pool.darker.action = nil
  next_at = moment() + next_from(delay_pool)
end

return {
  on_spawn = function()
    for index = 1, RANDOM_POOL_SIZE do
      delay_pool[index] = math.random(20, 30)
      count_pool[index] = math.random(3, 4)
    end

    ticker.every(math.random(3, 6) * 10, function()
      self.action = "lightning"
      trigger()
      pool.thunder:play()
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
      pool.darker.action = "default"
      if count >= total then
        active = false
        phase = PHASE_INACTIVE
        return
      end
      phase = PHASE_DARK
      next_at = moment() + next_from(delay_pool)
      return
    end

    pool.darker.action = nil
    phase = PHASE_BRIGHT
    next_at = moment() + next_from(delay_pool)
  end,

  on_touch = function()
    say("You cannot escape your own mind.", 3, 3, 3000)
  end,
}
