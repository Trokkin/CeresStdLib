require('CeresStdLib.base.basics')

local free_timers       = {
    handles             = {},
    stored              = {}
}
local Timer             = {
    __properties        = {
    }
}

--  For Hot Code Reload
if not free_timers.amount then
    free_timers.amount      = 0
end

free_timers.have        = function() return free_timers.amount > 0 end
free_timers.push        = function(t)
    if free_timers.stored[t] then return end
    free_timers.amount                          = free_timers.amount + 1
    free_timers.handles[free_timers.amount]     = t
    free_timers.stored[t]                       = true
end
free_timers.pop         = function()
    local t = free_timers.handles[free_timers.amount]
    free_timers.stored[t]                       = nil
    free_timers.handles[free_timers.amount]     = nil
    free_timers.amount                          = free_timers.amount - 1
    return t
end

--- Example: `doPeriodically(1/32, function(t) DestroyTimer(t) end)`
---@param period number
---@param func function
function doPeriodicaly(period, func)
	TimerStart(CreateTimer(), period, true, function() func(GetExpiredTimer()) DestroyTimer(GetExpiredTimer()) end)
end

---@param period number
---@param count integer
---@param func function
function doPeriodicalyCounted(period, count, func)
	if count < 1 then
		return
	end
	local i = count
	local t = CreateTimer()
	TimerStart(t, period, true, function()
		func()
		i = i - 1
		if i <= 0 then
			DestroyTimer(t)
		end
	end)
end

---@param period number
---@param duration number
---@param func function
function doPeriodicalyTimed(period, duration, func)
	if duration < period then
		return
	end
	doPeriodicalyCounted(period, math.floor(duration / period), func)
end

---@param timeToWait number
---@param func function
function doAfter(timeToWait, func)
	local t = CreateTimer()
	TimerStart(t, timeToWait, false, function() func() DestroyTimer(t) end)
end

---@param func function
function nullTimer(func)
	doAfter(0, func)
end
