require('CeresStdLib.base.Log')
require('CeresStdLib.base.Execute')
require('CeresStdLib.base.Init')

Unoptimized = {}
localplayer = nil
players = {}

localplayer = GetLocalPlayer()
for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
	players[i] = Player(i)
end

local function replaceNative(name, new_f)
	if not Unoptimized[name] then
		Unoptimized[name] = _G[name]
	end
	_G[name] = nil
end

--[[ -- TODO: fix
replaceNative("Player", function(i)
	return players[i]
end)
replaceNative("GetLocalPlayer", function()
	return localplayer
end)
]]