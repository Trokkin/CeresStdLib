require('CeresStdLib.container.List')
require('CeresStdLib.base.Init')

LogLevel = {
	TRACE = 0,
	DEBUG = 1,
	INFO = 2,
	WARNING = 3,
	ERROR = 4
}
LogLevel.Tags = {
	[LogLevel.TRACE] = '|cffADADADtrace|r - ',
	[LogLevel.DEBUG] = '|cff2685DCdebug|r - ',
	[LogLevel.INFO] = '|cffFFCC00info|r - ',
	[LogLevel.WARNING] = '|cffF47E3Ewarning|r - ',
	[LogLevel.ERROR] = '|cffFB2700error|r - '
}


DEBUG_LEVEL = -1 -- LogLevel.INFO
DEBUG_MSG_DURATION = 45

function LogLevel.getTag(level)
	local r = LogLevel.Tags[level]
	if r ~= nil then
		return r
	end
	return ''
end

Log = {}

local arr = {}
init(function()
	for i, p in pairs(arr) do
		DisplayTimedTextToPlayer(GetLocalPlayer(), 0., 0., DEBUG_MSG_DURATION,
			LogLevel.getTag(p.level) .. ' - ' .. p.msg)
	end
	arr = nil
end)

function printLog(level, msg)
	if DEBUG_LEVEL <= level then
		if arr ~= nil then
			table.insert(arr, {level = level, msg = msg})
		else
			DisplayTimedTextToPlayer(GetLocalPlayer(), 0., 0., DEBUG_MSG_DURATION,
				LogLevel.getTag(level) .. ' - ' .. msg)
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
