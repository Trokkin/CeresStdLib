require('CeresStdLib.base.Native')
require('CeresStdLib.base.Optimizations')
require('CeresStdLib.base.Rawcode')
require('CeresStdLib.base.Execute')
require('CeresStdLib.base.Log')
require('CeresStdLib.base.Init')

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

local META_TABLE    = {
    TABLES          = {},
    METATABLES      = {},
    NAME            = {},
    __metatable     = false
}
META_TABLE.__index      = function(t, k)
    return META_TABLE.METATABLES[t][k]
end
META_TABLE.__newindex   = function(t, k, v)
    Log.warn('Attempted to assign value ' .. tostring(v) .. ' to key ' .. k .. ' in readonly table ' .. (META_TABLE.NAME[t] or '') .. '.') 
end

function makeReadonly(table, name)
    -- local lastMetatable     = getmetatable(table)    
    --  If the table is already readonly, return the proxy table
    if META_TABLE.TABLES[table] then return META_TABLE.TABLES[table] end
    
    local proxy                     = {}
    META_TABLE.METATABLES[proxy]    = table
    META_TABLE.TABLES[table]        = proxy

    if name then META_TABLE.NAME[proxy] = name end
    
    setmetatable(proxy, META_TABLE)
    return proxy
end

local __oldInitB = InitBlizzard
InitBlizzard = function()
    pcall(__oldInitB)
end
