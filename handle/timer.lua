require('CeresStdLib.base.basics')
require('CeresStdLib.handle.handle')

Timer					= Handle:new()
Timer.__props.remaining	= {get 		= function(t) return TimerGetRemaining(t.__obj) end}
Timer.__props.timeout	= {get 		= function(t) return TimerGetTimeout(t.__obj) end}
Timer.__props.elapsed	= {get 		= function(t) return TimerGetElapsed(t.__obj) end}

function Timer.create() return Timer.wrap(CreateTimer()) end
function Timer.getExpired() return Timer.wrap(GetExpiredTimer()) end

function Timer:resume()	
	if not self.hasCallback then Log.error('Timer:resume >> Cannot resume a timer which hasn\t started yet!') return end
	if not self.inCallback then
		ResumeTimer(self.__obj) 
	else
		self.hasResumed = true
		if self.looped then
			self.loopBroken = true
		end
	end
end
function Timer:pause() 
	if self.running then
		self.running 	= false
		PauseTimer(self.__obj)
	end
end
function Timer:start(dur, looped, func)
	self.hasCallback = true
	if not self.inCallback then
		self.dur		= dur
		self.looped		= looped
		self.func		= func
		self.running	= true

		TimerStart(self.__obj, dur, looped, function()
			self.running	= false
			self.inCallback = true
			self.func()
			self.inCallback = false

			if self.onDestroy then
				self.onDestroy	= nil
				self:destroy()
			elseif self.hasNewParams then
				self.hasNewParams	= nil
				self.running		= true
				self:pause()
				self:start(self.newDur, self.newLooped, self.newFunc)
			
				self.newDur			= nil
				self.newLooped		= nil
				self.newFunc		= nil
			elseif not self.looped and self.hasResumed then
				self.hasResumed 	= nil
				self:start(self.dur, self.looped, self.func)
			elseif self.loopBroken then
				self.loopBroken		= nil
				self.hasResumed		= nil
				self:start(self.dur, self.looped, self.func)
			end
		end) 
	else
		self.hasNewParams	= true
		self.newDur			= dur
		self.newLooped		= looped
		self.newFunc		= func
	end
end
function Timer:destroy()
	if self.inCallback then
		self.onDestroyFlag = true
		return
	end
	if self.running then
		self:pause()
	end 
	DestroyTimer(self.__obj)
	self:unwrap()
end

--- Example: `doPeriodically(1/32, function(t) end)`
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
