require('CeresStdLib.base.Init')

base.Log.Log	= base.Log.Log or {}
base.Log.LogLevel	= base.Log.LogLevel or {
	TRACE = 0,
	DEBUG = 1,
	INFO = 2,
	WARNING = 3,
	ERROR = 4
}
LogLevel		= base.LogLevel
LogLevel.Tags 	= LogLevel.Tags or {
	[LogLevel.TRACE] = '|cffADADADtrace|r - ',
	[LogLevel.DEBUG] = '|cff2685DCdebug|r - ',
	[LogLevel.INFO] = '|cffFFCC00info|r - ',
	[LogLevel.WARNING] = '|cffF47E3Ewarning|r - ',
	[LogLevel.ERROR] = '|cffFB2700error|r - '
}

DEBUG_LEVEL = -1 -- LogLevel.INFO

function LogLevel.getTag(level)
	local r = LogLevel.Tags[level]
	if r ~= nil then
		return r
	end
	return ''
end

base.arr	
Log 		= base.Log

local arr = {}
init(function()
	for i, p in pairs(arr) do
		print(LogLevel.getTag(p.level), table.unpack(p.msg))
	end
	arr = nil
end)

function printLog(level, ...)
	if DEBUG_LEVEL <= level then
		if arr ~= nil then
			table.insert(arr, {level = level, msg = {...}})
		else
			print(LogLevel.getTag(level), ...)
		end
	end
end

function Log.trace(...)
	printLog(LogLevel.TRACE, ...)
end
function Log.debug(...)
	printLog(LogLevel.DEBUG, ...)
end
function Log.info(...)
	printLog(LogLevel.INFO, ...)
end
function Log.warn(...)
	printLog(LogLevel.WARNING, ...)
end
function Log.error(...)
	printLog(LogLevel.ERROR, ...)
end
function Log.setLevel(level)
	DEBUG_LEVEL = level
end
