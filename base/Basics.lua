require('CeresStdLib.base.Native')
require('CeresStdLib.base.Optimizations')
require('CeresStdLib.base.Rawcode')
require('CeresStdLib.base.Execute')
require('CeresStdLib.base.Log')
require('CeresStdLib.base.Init')
require('CeresStdLib.base.readonly')

ANIMATION_PERIOD = 1 / 32.
MAX_COLLISION_SIZE = 197.

HEIGHT_ENABLER      = fromRawCode('Amrf')
TREE_RECOGNITION    = fromRawCode('Aeat')
LOCUST_ID           = fromRawCode('Aloc')
GHOST_INVIS_ID      = fromRawCode('Agho')
GHOST_VIS_ID        = fromRawCode('Aeth')
DETECT_LEAVE        = fromRawCode('Amdf')

DUMMY_PLAYER = players[PLAYER_NEUTRAL_PASSIVE]
DUMMY_HOSTILE_PLAYER = players[PLAYER_NEUTRAL_AGGRESSIVE]

local __oldInitB = InitBlizzard
InitBlizzard = function()
    pcall(__oldInitB)
end
