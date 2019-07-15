require('CeresStdLib.base.Native')
require('CeresStdLib.base.Log')
local free_timers = {}

replaceNative('CreateTimer', function()
	k, v = next(free_timers)
	if k ~= nil then
		free_timers[k] = nil
		return k
	else
		return Native.CreateTimer()
	end
end)

replaceNative('DestroyTimer', function(t)
	if t == nil then
		Log.error('DestroyTimer: null timer')
		return
	end
	if free_timers[t] then
		Log.error('DestroyTimer: double free')
		return
	end
	PauseTimer(t)
	free_timers[t] = true
end)

--- Use `DestroyTimer(arg[1])` to stop this.
--- Example: `doPeriodically(1/32, function(t) if done then DestroyTimer(t) end end)`
---@param period number
---@param func function
function doPeriodicaly(period, func)
	local t = CreateTimer()
	TimerStart(t, period, true, function() func(t) DestroyTimer(GetExpiredTimer()) end)
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
