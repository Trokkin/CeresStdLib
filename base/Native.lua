require('CeresStdLib.base.Log')

--- It is generally not recommended to use old natives.
Native = {}

function replaceNative(name, new_f)
	if not _G[name] then
		Log.warn('replaceNative: ' .. name .. ' is not a native.')
	end
	if not Native[name] and _G[name] then
		Native[name] = _G[name]
	end
	_G[name] = new_f
end