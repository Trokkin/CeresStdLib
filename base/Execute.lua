require('CeresStdLib.base.Log')

function execute(f)
	s, r = pcall(f)
	if not s then
		Log.error(r)
		return nil
	end
	return r
end