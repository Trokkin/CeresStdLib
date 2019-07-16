require('CeresStdLib.base.Log')
require('CeresStdLib.base.Native')

--- Safely executes the function, and in case of an error, call `handler(msg)` and returns `nil`.
--- Else, returns everything what was returned by the function.
---@param f function
---@param handler function
function xexecute(f, handler, ...)
	r = {pcall(f, ...)}
	if not r[1] then
		if handler ~= nil then
			handler(table.unpack(r, 2))
		end
		return nil
	end
	return table.unpack(r, 2)
end

--- Safely executes the function, and in case of an error, prints it in Log and returns `nil`.
--- Else, returns everything what was returned by the function.
---@param f function
function execute(f, ...)
	return xexecute(f, function(msg) Log.error(msg) end, ...)
end

replaceNative('assert', function(...)
	execute(Native.assert, ...)
end)
