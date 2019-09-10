-- This basically (pun intended) is a legacy from wurstStdLib
require('CeresStdLib.base.optimizations')

ANIMATION_PERIOD = 1 / 32.
MAX_COLLISION_SIZE = 197.

HEIGHT_ENABLER      = FourCC('Amrf')
TREE_RECOGNITION    = FourCC('Aeat')
LOCUST_ID           = FourCC('Aloc')
GHOST_INVIS_ID      = FourCC('Agho')
GHOST_VIS_ID        = FourCC('Aeth')
DETECT_LEAVE        = FourCC('Amdf')

DUMMY_PLAYER = players[PLAYER_NEUTRAL_PASSIVE]
DUMMY_HOSTILE_PLAYER = players[PLAYER_NEUTRAL_AGGRESSIVE]

replaceNative('InitBlizzard', function()
    pcall(Native.InitBlizzard)
end)
