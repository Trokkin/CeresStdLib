require('CeresStdLib.base.Native')
require('CeresStdLib.base.Log')

local Timer 		= {}
local free_timers	= {}
local MAX_PUSHES	= 10000		--	Maximum amount of times push is called before garbage collection.

free_timers.free	= 0
free_timers.steps	= 0

free_timers.has = function() return free_timers.free > 0 end

free_timers.push = function(t)
	--	When the number of steps exceeds MAX_PUSHES, collect garbage
	if free_timers.steps >= MAX_PUSHES then
		collectgarbage()
	end
	if not free_timers[GetHandleId(t)] then
		free_timers.free 				= free_timers.free + 1
		free_timers[GetHandleId(t)] 	= true
		free_timers[free_timers.free]	= t
		free_timers.steps				= free_timers.steps + 1
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
	if Timer[GetHandleId(t)].running then
		Timer[GetHandleId(t)].running    = nil
		Timer[GetHandleId(t)].pauseFlag  = (BlzBitOr(Timer[GetHandleId(t)].pauseFlag, 1))
	end
	Native.PauseTimer(t)
end)

replaceNative('ResumeTimer', function(t)
	if not Timer[GetHandleId(t)].hasCallback then
		Log.error("ResumeTimer: Attempted to resume a timer " .. I2S(GetHandleId(t)) .. " with no callback")
		return
	end
	if Timer[GetHandleId(t)].inCallback and Timer[GetHandleId(t)].looped then
		Log.warn("ResumeTimer: Do not resume a looped timer " .. I2S(GetHandleId(t)) .. " manually.")
		return
	end
	if not Timer[GetHandleId(t)].running then
		Timer[GetHandleId(t)].running    = true
	end
	Native.ResumeTimer(t)
end)

replaceNative('TimerStart', function(t, dur, looper, func)
	Timer[GetHandleId(t)].hasCallback = true
	if not Timer[GetHandleId(t)].inCallback then
		--  Usually when a timer is created
		Timer[GetHandleId(t)].duration   = math.max(dur, 0.)
		Timer[GetHandleId(t)].looped     = looper
		Timer[GetHandleId(t)].callback   = func
		Timer[GetHandleId(t)].running    = true

		--  Create a new function that will act as the callback
		Native.timerStart(t, dur, looper, function()
			local tr = GetExpiredTimer()
   
			Timer[GetHandleId(tr)].inCallback = true
			Timer[GetHandleId(tr)].running    = false
			Timer[GetHandleId(tr)].callback()
   
			Timer[GetHandleId(tr)].inCallback = false
			if Timer[GetHandleId(tr)].onDestroyFlag then
				DestroyTimer(tr)
			elseif Timer[GetHandleId(tr)].tempData then
				--  Properties of the timer were overwritten
				Native.PauseTimer(tr)
				TimerStart(tr, Timer[GetHandleId(tr)].tempData.dur, Timer[GetHandleId(tr)].tempData.looper, Timer[GetHandleId(tr)].tempData.func)
				Timer[GetHandleId(tr)].tempData = nil
				Timer[GetHandleId(tr)].elapsed = 0.
			else
				if Timer[GetHandleId(tr)].looped and ((BlzBitAnd(Timer[GetHandleId(tr)].pauseFlag, 1) ~= 0) or (BlzBitAnd(Timer[GetHandleId(tr)].pauseFlag, 2) ~= 0)) then
					Timer[GetHandleId(tr)].pauseFlag  = 0
					Native.PauseTimer(tr)
					TimerStart(tr, Timer[GetHandleId(tr)].duration, Timer[GetHandleId(tr)].looped, Timer[GetHandleId(tr)].callback)
				elseif Timer[GetHandleId(tr)].looped then
					Timer[GetHandleId(tr)].running    = true
				end
				Timer[GetHandleId(tr)].elapsed = 0.
			end
		end)
	else
		--	If TimerStart was called within the callback, store the parameter values.
		--	To be used when the callback function is done.
		if not Timer[GetHandleId(t)].tempData then
			Timer[GetHandleId(t)].tempData = {__mode='k'}
		end
		Timer[GetHandleId(t)].tempData.dur 		= dur
		Timer[GetHandleId(t)].tempData.looper 	= looper
		Timer[GetHandleId(t)].tempData.func 	= func
	end
end)

replaceNative('DestroyTimer', function(t)
	if not Timer[GetHandleId(t)].hasCallback then
		Timer[GetHandleId(t)]    = nil
		free_timers.push(t)
		return
	end
	if not Timer[GetHandleId(t)] or Timer[GetHandleId(t)].inCallback then
		--  No need to destroy an already-destroyed timer
		if Timer[GetHandleId(t)].inCallback then
			Timer[GetHandleId(t)].onDestroyFlag  = true
		end
		return
	end
	if Timer[GetHandleId(t)].onDestroyFlag then
		Timer[GetHandleId(t)].onDestroyFlag = nil
	end
	if Timer[GetHandleId(t)].running or Timer[GetHandleId(t)].looped then
		Timer[GetHandleId(t)].running = nil
		Native.PauseTimer(t)
	end
	Timer[GetHandleId(t)]    = nil
	free_timers.push(t)
end)

replaceNative('TimerGetTimeout', function(t) return Timer[GetHandleId(t)].duration end)
replaceNative('TimerGetElapsed', function(t) return Native.TimerGetElapsed(t) + Timer[GetHandleId(t)].elapsed end)

-- @param t timer
-- @param newR new remaining
-- @param update update the total duration
function TimerSetRemaining(t, newR, update)
	if Timer[GetHandleId(t)].inCallback then
		Log.warn('TimerSetRemaining: The remaining duration of the timer ' .. I2S(GetHandleId(t)) .. ' cannot be altered while the callback function is running.')
		return false
	end
	if not Timer[GetHandleId(t)].hasCallback then
		Log.warn('TimerSetRemaining: The remaining duration of the timer ' .. I2S(GetHandleId(t)) .. ' cannot be altered while the timer has not yet started.')
		return false
	end
	--  Ensure that newR is not below 0.       
	newR                = math.max(newR, 0.)
	local epsilon       = Native.TimerGetElapsed(t)
	local delta         = TimerGetRemaining(t) - newR
	local newDur        = Timer[GetHandleId(t)].duration - delta
	--  If delta is anything but 0., continue with TimerSetRemaining
	if delta ~= 0. then
		Native.PauseTimer(t)
		Native.TimerStart(t, newR, Timer[GetHandleId(t)].looped, Timer[GetHandleId(t)].callback)
		Timer[GetHandleId(t)].elapsed    = Timer[GetHandleId(t)].elapsed + epsilon
		if update then
			Timer[GetHandleId(t)].duration   = newDur
		end
		Timer[GetHandleId(t)].pauseFlag  = (BlzBitOr(Timer[GetHandleId(t)].pauseFlag, 2))
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
