require('CeresStdLib.base.Log')
require('CeresStdLib.base.Execute')
require('CeresStdLib.base.Init')

Unoptimized = {}
players = {}

for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
	players[i] = Player(i)
end
localplayer = nil


local function replaceNative(name, new_f)
	if not Unoptimized[name] and _G[name] then
		Unoptimized[name] = _G[name]
	end
	_G[name] = new_f
end

replaceNative("Player", function(i) return players[i] end)

ceres.addHook("main::before", function()
	localplayer = GetLocalPlayer()
	replaceNative("GetLocalPlayer", function() return localplayer end)
end)
