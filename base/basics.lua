require('CeresStdLib.folders')

require('CeresStdLib.base.native')
require('CeresStdLib.base.optimizations')
require('CeresStdLib.base.rawcode')
require('CeresStdLib.base.execute')
require('CeresStdLib.base.log')
require('CeresStdLib.base.init')
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

replaceNative('InitBlizzard', function()
    pcall(Native.InitBlizzard)
end)