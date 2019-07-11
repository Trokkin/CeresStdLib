require('CeresStdLib.base.Log')

--- Safely executes the function, and in case of an error, prints it in Log and returns `nil`.
--- Else, returns everything what was returned by the function.
function execute(f, ...)
	r = {pcall(f, ...)}
	if not r[1] then
		Log.error(r[2])
		return nil
	end
	return table.unpack(r, 2)
end