require('CeresStdLib.base.Native')

players = {}
for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
	players[i] = Player(i)
end
localplayer = nil

replaceNative("Player", function(i) return players[i] end)

ceres.addHook("main::before", function()
	localplayer = GetLocalPlayer()
	replaceNative("GetLocalPlayer", function() return localplayer end)
end)
