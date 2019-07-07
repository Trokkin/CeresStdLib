--- It is generally not recommended to use old natives.
Native = {}

function replaceNative(name, new_f)
	if not Native[name] and _G[name] then
		Native[name] = _G[name]
	end
	_G[name] = new_f
end