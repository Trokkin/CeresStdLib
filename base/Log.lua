require('CeresStdLib.container.List')

LogLevel = {
	TRACE = 0,
	DEBUG = 1,
	INFO = 2,
	WARNING = 3,
	ERROR = 4
}

DEBUG_LEVEL = -1 -- LogLevel.INFO
DEBUG_MSG_DURATION = 45

function LogLevel.getTag(level)
	if level < 2 then
		if level < 1 then
			return '|cffADADADtrace|r'
		else
			return '|cff2685DCdebug|r'
		end
	end
	if level > 2 then
		if level < 4 then
			return '|cffF47E3Ewarning|r'
		else
			return '|cffFB2700error|r'
		end
	end
	return '|cffFFCC00info|r'
end

Log = {}
---@type List
Log.storage = List:new()

ceres.addHook("main::after", function()
	for i = Log.storage.first, Log.storage.last do
		p = Log.storage[i]
		if DEBUG_LEVEL <= p.level then
			DisplayTimedTextToPlayer(
				GetLocalPlayer(),
				0.,
				0.,
				DEBUG_MSG_DURATION,
				LogLevel.getTag(p.level) .. ' - ' .. p.msg
			)
		end
	end
	Log.storage = nil
end)

function printLog(level, msg)
	if Log.storage ~= nil then
		local q = { level = level, msg = msg }
		
		List.pushright(Log.storage, q)
		-- Log.storage:pushright(q) -- TODO: fix metatable?
	else
		if DEBUG_LEVEL <= level then
			DisplayTimedTextToPlayer(
				GetLocalPlayer(),
				0.,
				0.,
				DEBUG_MSG_DURATION,
				LogLevel.getTag(level) .. ' - ' .. msg
			)
		end
	end
end

function Log.trace(msg)
	printLog(LogLevel.TRACE, msg)
end
function Log.debug(msg)
	printLog(LogLevel.DEBUG, msg)
end
function Log.info(msg)
	printLog(LogLevel.INFO, msg)
end
function Log.warn(msg)
	printLog(LogLevel.WARNING, msg)
end
function Log.error(msg)
	printLog(LogLevel.ERROR, msg)
end
function Log.setLevel(level)
	DEBUG_LEVEL = level
end
