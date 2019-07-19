require('CeresStdLib.base.log')
require('CeresStdLib.base.native')

local function _xexecute(handler, success, msg, ...)
	if not success then
		if handler ~= nil then
			handler(msg, ...)
		end
		return nil
	end
	return msg, ...
end

--- Safely executes the function, and in case of an error, call `handler(msg)` and returns `nil`.
--- Else, returns everything what was returned by the function.
---@param f function
---@param handler function
function xexecute(f, handler, ...)
	return _xexecute(handler, pcall(f, ...))
end

--- Safely executes the function, and in case of an error, prints it in Log and returns `nil`.
--- Else, returns everything what was returned by the function.
---@param f function
function execute(f, ...)
	return _xexecute(function(msg) Log.error(msg) end, pcall(f, ...))
end

replaceNative('assert', function(...)
	execute(Native.assert, ...)
end)
