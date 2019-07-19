require('CeresStdLib.base.basics')

Timer			= {
	__handles	= {},
	__props		= {
		id			= {
				get	= function(t) return GetHandleId(t.__obj) end
		},
		remaining	= {
				get = function(t) return TimerGetRemaining(t.__obj) end
		},
		timeout		= {
				get = function(t) return TimerGetTimeout(t.__obj) end
		},
		elapsed		= {
				get = function(t) return TimerGetElapsed(t.__obj) end
		},
		handle		= {
				get = function(t) return t.__obj end
		}
	}
}

function Timer.__index(t, k)
	if Timer.__props[k].get then
		return Timer.__props[k].get(t)
	end
	return t[k]
end

function Timer.__newindex(t, k, v)
	if Timer.__props[k].set then
		Timer.__props[k].set(t, v)
	end
	rawset(t, k, v)
end

function Timer.wrap(t)
	local i = GetHandleId(t)
	if not Timer.__handles[i] then
		Timer.__handles[i] = {obj = t}
		setmetatable(Timer.__handles[i], Timer)
	end
	return Timer.__handles[i]
end

function Timer:unwrap()	Timer.__handles[self.id] = nil end

function Timer.create()	return Timer.wrap(CreateTimer()) end
function Timer.getExpired() return Timer.wrap(GetExpiredTimer()) end

function Timer:resume()	ResumeTimer(self.__obj) end
function Timer:start(dur, looped, func)	TimerStart(self.__obj, dur, looped, func) end
function Timer:pause() PauseTimer(self.__obj) end

function Timer:destroy() DestroyTimer(self.__obj) self:unwrap() end

--- Example: `doPeriodically(1/32, function(t) DestroyTimer(t) end)`
---@param period number
---@param func function
function doPeriodicaly(period, func)
	Timer.create():start(period, true, function() func(GetExpiredTimer()) end)
end

---@param period number
---@param count integer
---@param func function
function doPeriodicalyCounted(period, count, func)
	if count < 1 then
		return
	end
	local i = count
	local t = Timer.create()
	t:start(period, true, function()
		func()
		i = i - 1
		if i <= 0 then
			t:pause()
			t:destroy()
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
	Timer.create():start(timeToWait, false, function() func(GetExpiredTimer()) Timer.getExpired():destroy() end)
end

---@param func function
function nullTimer(func)
	doAfter(0, func)
end
