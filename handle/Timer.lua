require('CeresStdLib.base.Native')
require('CeresStdLib.base.Log')

local Timer 		= {}
local free_timers	= {}
local MAX_PUSHES	= 10000		--	Maximum amount of times push is called before garbage collection.

free_timers[0]		= 0
free_timers[-1]		= 0

free_timers.has = function()
	if free_timers[0] <= 0 then return false end return true
end

free_timers.push = function(t)
	if free_timers[-1] >= MAX_PUSHES then
		collectgarbage()
	end
	if not free_timers[t] then
		free_timers[0] 					= free_timers[0] + 1
		free_timers[t] 					= true
		free_timers[free_timers[0]]		= t
		free_timers[-1]					= free_timers[-1] + 1
		return true
	end
	return false
end

free_timers.pop = function()
	local obj
	if free_timers[0] > 0 then
		obj = free_timers[free_timers[0]]
		free_timers[obj] 	= nil
		free_timers[0] 		= free_timers[0] - 1
		return obj
	end
	return nil
end

replaceNative('CreateTimer', function()
	local obj
	if free_timers.has() then
		obj = free_timers.pop()
	else
		obj = Native.CreateTimer()
	end
	Timer[obj]      = {
		hasCallback = nil,
		callback    = nil,
		looped      = nil,
		running     = nil,
		inCallback  = nil,
		pauseFlag   = 0,
		duration    = 0.,
		elapsed     = 0.
	}
	return obj
end)

replaceNative('PauseTimer', function(t)
	if Timer[t].running then
		Timer[t].running    = nil
		Timer[t].pauseFlag  = (BlzBitOr(Timer[t].pauseFlag, 1))
	end
	Native.PauseTimer(t)
end)

replaceNative('ResumeTimer', function(t)
	if not Timer[t].hasCallback then
		Log.error("ResumeTimer: Attempted to resume a timer " .. I2S(GetHandleId(t)) .. " with no callback")
		return
	end
	if Timer[t].inCallback and Timer[t].looped then
		return
	end
	if not Timer[t].inCallback and not Timer[t].running then
		Timer[t].running    = 0
	end
	Native.ResumeTimer(t)
end)

replaceNative('TimerStart', function(t, dur, looper, func)
	if not Timer[t].hasCallback then
		--  Make it come true
		Timer[t].hasCallback = 0
	end
	if not Timer[t].inCallback then
		--  Usually when a timer is created
		Timer[t].duration   = math.max(dur, 0.)
		Timer[t].looped     = looper
		Timer[t].callback   = func
		Timer[t].running    = 0

		--  Create a new function that will act as the callback
		Native.timerStart(t, dur, looper, function()
			local tr = GetExpiredTimer()
   
			Timer[tr].inCallback = 0
			Timer[tr].running    = nil
			Timer[tr].callback()
   
			Timer[tr].inCallback = nil
			if Timer[tr].destroyFlag then
				DestroyTimer(tr)
			elseif Timer[tr].tempData then
				--  Properties of the timer were overwritten
				Native.PauseTimer(tr)
				TimerStart(tr, Timer[tr].tempData.dur, Timer[tr].tempData.looper, Timer[tr].tempData.func)
				Timer[tr].tempData = nil
				Timer[tr].elapsed = 0.
			else
				if Timer[tr].looped and ((BlzBitAnd(Timer[tr].pauseFlag, 1) ~= 0) or (BlzBitAnd(Timer[tr].pauseFlag, 2) ~= 0)) then
					Timer[tr].pauseFlag  = BlzBitAnd(Timer[tr].pauseFlag, 0)
					Native.PauseTimer(tr)
					TimerStart(tr, Timer[tr].duration, Timer[tr].looped, Timer[tr].callback)
				elseif Timer[tr].looped then
					Timer[tr].running    = 0
				end
				Timer[tr].elapsed = 0.
			end
		end)
	else
		if not Timer[t].tempData then
			Timer[t].tempData = {__mode='k'}
		end
		Timer[t].tempData.dur = dur
		Timer[t].tempData.looper = looper
		Timer[t].tempData.func = func
	end
end)

replaceNative('DestroyTimer', function(t)
	if not Timer[t].hasCallback then
		Timer[t]    = nil
		free_timers.push(t)
		return
	end
	if not Timer[t] or Timer[t].inCallback then
		--  No need to destroy an already-destroyed timer
		if Timer[t].inCallback then
			Timer[t].onDestroyFlag  = 0
		end
		return
	end
	if Timer[t].onDestroyFlag then
		Timer[t].onDestroyFlag = nil
	end
	if Timer[t].running or Timer[t].looped then
		Timer[t].running = nil
		Native.PauseTimer(t)
	end
	Timer[t]    = nil
	free_timers.push(t)
end)

replaceNative('TimerGetTimeout', function(t) return Timer[t].duration end)
replaceNative('TimerGetElapsed', function(t) return Native.TimerGetElapsed(t) + Timer[t].elapsed end)

function TimerSetRemaining(t, newR, update)
	if Timer[t].inCallback then
		Log.warn('TimerSetRemaining: The remaining duration of the timer ' .. I2S(GetHandleId(t)) .. ' cannot be altered while the callback function is running.')
		return false
	end
	if not Timer[t].hasCallback then
		Log.warn('TimerSetRemaining: The remaining duration of the timer ' .. I2S(GetHandleId(t)) .. ' cannot be altered while the timer has not yet started.')
		return false
	end
	--  Ensure that newR is not below 0.       
	newR                = math.max(newR, 0.)
	local epsilon       = Native.TimerGetElapsed(t)
	local delta         = TimerGetRemaining(t) - newR
	local newDur        = Timer[t].duration - delta
	--  If delta is anything but 0., continue with TimerSetRemaining
	if delta ~= 0. then
		Native.PauseTimer(t)
		Native.TimerStart(t, newR, Timer[t].looped, Timer[t].callback)
		Timer[t].elapsed    = Timer[t].elapsed + epsilon
		if update then
			Timer[t].duration   = newDur
		end
		Timer[t].pauseFlag  = (BlzBitOr(Timer[t].pauseFlag, 2))
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
