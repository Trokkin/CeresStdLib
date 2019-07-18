require('CeresStdLib.base.Native')
require('CeresStdLib.base.Log')

local Timer 		= {}
local free_timers	= {}

FLAG_TIMER_PAUSED	= 1
FLAG_TIMER_ALTERED	= 2
FLAG_TIMER_RESUMED	= 4

free_timers.free	= 0
free_timers.has = function() return free_timers.free > 0 end
free_timers.push = function(t)
	if not free_timers[GetHandleId(t)] then
		free_timers.free 				= free_timers.free + 1
		free_timers[GetHandleId(t)] 	= true
		free_timers[free_timers.free]	= t
		return true
	end
	return false
end
free_timers.pop = function()
	local obj
	if free_timers.free > 0 then
		obj 							= free_timers[free_timers.free]
		free_timers[GetHandleId(obj)] 	= nil 
		free_timers[free_timers.free]	= nil
		free_timers.free 				= free_timers.free - 1
	end
	return obj
end

replaceNative('CreateTimer', function()
	local obj
	if free_timers.has() then
		obj = free_timers.pop()
	else
		obj = Native.CreateTimer()
	end
	Timer[GetHandleId(obj)]      = {
		hasCallback = false,
		looped      = false,
		running     = false,
		inCallback  = false,
		callback    = nil,
		pauseFlag   = 0,
		duration    = 0.,
		elapsed     = 0.
	}
	return obj
end)

replaceNative('PauseTimer', function(t)
	local i = GetHandleId(t)
	if Timer[i].running then
		Timer[i].running    = nil
		Timer[i].pauseFlag  = (BlzBitOr(Timer[i].pauseFlag, FLAG_TIMER_PAUSED))
	end
	Native.PauseTimer(t)
end)

replaceNative('ResumeTimer', function(t)
	local i = GetHandleId(t)
	if not Timer[i].hasCallback then
		Log.error("ResumeTimer: Attempted to resume a timer " .. I2S(i) .. " with no callback")
		return
	end
	if Timer[i].inCallback and Timer[i].looped then
		Log.error("ResumeTimer: Attempted to resume a looped timer " .. I2S(i) .. " manually.")
		return
	end
	if not Timer[i].running then
		if Timer[i].inCallback then
			Timer[i].pauseFlag	= BlzBitOr(Timer[i].pauseFlag, FLAG_TIMER_RESUMED)
		else
			Timer[i].running    = true
			Native.ResumeTimer(t)
		end
	end
end)

local timerCallback = nil
replaceNative('TimerStart', function(t, dur, looper, func)
	local i = GetHandleId(t)
	Timer[i].hasCallback = true
	if not Timer[i].inCallback then
		--  Usually when a timer is created
		Timer[i].duration   = math.max(dur, 0.)
		Timer[i].looped     = looper
		Timer[i].callback   = func
		Timer[i].running    = true

		--  Create a new function that will act as the callback
		Native.TimerStart(t, Timer[i].duration, looper, timerCallback)
	else
		--	If TimerStart was called within the callback, store the parameter values.
		--	To be used when the callback function is done.
		if not Timer[i].tempData then
			Timer[i].tempData = {__mode='k'}
		end
		Timer[i].tempData.dur 		= dur
		Timer[i].tempData.looper 	= looper
		Timer[i].tempData.func 		= func
	end
end)

replaceNative('DestroyTimer', function(t)
	local i = GetHandleId(t)
	if not Timer[i].hasCallback then
		Timer[i]    = nil
		free_timers.push(t)
		return
	end
	if not Timer[i] or Timer[i].inCallback then
		--  No need to destroy an already-destroyed timer
		if Timer[i].inCallback then
			Timer[i].onDestroyFlag  = true
		end
		return
	end
	if Timer[i].onDestroyFlag then
		Timer[i].onDestroyFlag = nil
	end
	if Timer[i].running or Timer[i].looped then
		Timer[i].running = nil
		Native.PauseTimer(t)
	end
	Timer[i]    = nil
	free_timers.push(t)
end)

replaceNative('TimerGetTimeout', function(t) return Timer[GetHandleId(t)].duration end)
replaceNative('TimerGetElapsed', function(t) return Native.TimerGetElapsed(t) + Timer[GetHandleId(t)].elapsed end)

timerCallback = function()
	local tr 	= GetExpiredTimer()
	local ir	= GetHandleId(tr)

	Timer[ir].inCallback = true
	Timer[ir].running    = false
	Timer[ir].callback()

	Timer[ir].inCallback = false
	if Timer[ir].onDestroyFlag then
		DestroyTimer(tr)
	elseif Timer[ir].tempData then
		--  Properties of the timer were overwritten
		Native.PauseTimer(tr)
		TimerStart(tr, Timer[ir].tempData.dur, Timer[ir].tempData.looper, Timer[ir].tempData.func)
		Timer[ir].tempData 	= nil
		Timer[ir].elapsed 	= 0.
	else
		if Timer[ir].looped then
			if ((BlzBitAnd(Timer[ir].pauseFlag, FLAG_TIMER_PAUSED) ~= 0) or (BlzBitAnd(Timer[ir].pauseFlag, FLAG_TIMER_ALTERED) ~= 0)) then
				Timer[ir].pauseFlag  = 0
				Native.PauseTimer(tr)
				TimerStart(tr, Timer[ir].duration, Timer[ir].looped, Timer[ir].callback)
			else
				Timer[ir].running    = true
			end
		elseif BlzBitAnd(Timer[ir].pauseFlag, FLAG_TIMER_RESUMED) ~= 0 then
			print('Timer was resumed')
			Timer[ir].pauseFlag  = 0
			TimerStart(tr, Timer[ir].duration, Timer[ir].looped, Timer[ir].callback)
		end
		Timer[ir].elapsed = 0.
	end
end

-- @param t timer
-- @param newR new remaining
-- @param update update the total duration
function TimerSetRemaining(t, newR, update)
	local i = GetHandleId(t)
	if Timer[i].inCallback then
		Log.warn('TimerSetRemaining: The remaining duration of the timer ' .. I2S(i) .. ' cannot be altered while the callback function is running.')
		return false
	elseif not Timer[i].hasCallback then
		Log.warn('TimerSetRemaining: The remaining duration of the timer ' .. I2S(i) .. ' cannot be altered while the timer has not yet started.')
		return false
	end
	--  Ensure that newR is not below 0.       
	newR                = math.max(newR, 0.)
	local epsilon       = Native.TimerGetElapsed(t)
	local delta         = TimerGetRemaining(t) - newR
	local newDur        = Timer[i].duration - delta
	--  If delta is anything but 0., continue with TimerSetRemaining
	if delta ~= 0. then
		Native.PauseTimer(t)
		Native.TimerStart(t, newR, Timer[i].looped, Timer[i].callback)
		Timer[i].elapsed    = Timer[i].elapsed + epsilon
		if update then
			Timer[i].duration   = newDur
		else
			Timer[i].duration	= newDur + delta
		end
		Timer[i].pauseFlag  = (BlzBitOr(Timer[i].pauseFlag, FLAG_TIMER_ALTERED))
		return true
	end
	return false
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
