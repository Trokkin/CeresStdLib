--[[
    UnitEvent (Namesake)
        Originally by Bribe

    Uses Magic Defense instead of Defend ability to detect leave.    
]]

require('CeresStdLib.base.Rawcode')
require('CeresStdLib.base.Optimizations')
require('CeresStdLib.base.Native')
require('CeresStdLib.base.Init')
require('CeresStdLib.base.Log')

require('CeresStdLib.util.World')

DETECT_LEAVE            = fromRawCode('Amdf')

EVENT_UNIT_ENTER        = 1
EVENT_UNIT_LEAVE        = 2

UnitEvent = {}

local trigTable         = {}
local __userData        = {}
__userData[-1]          = {}   --  Holds references to each unit
__userData[-2]          = {}   --  Holds preplaced flag
__userData[0]           = 0

trigTable[3], trigTable[4]                  = {}, {}

local __evType          = 0
local __evData          = {0, nil}
local __initialized     = false

replaceNative('GetUnitUserData', function(u)
    return __userData[u]
end)
replaceNative('SetUnitUserData', function(u, newField)
    __userData[u] = newField
end)

function __userData:alloc()
    local i = __userData[0]
    if i == 0 then
        i                   = i + 1
        __userData[0]       = i
        return i
    end
    if (not __userData[i]) or (__userData[i] == 0) then
        __userData[0]     = i + 1
        __userData[i]     = -1
        i                 = __userData[0]
    else
        __userData[0]     = __userData[i]
        __userData[i]     = -1
    end
    return i
end

function __userData:dealloc(i)
    if (not i) or (__userData[i] ~= -1) then return end

    __userData[i], __userData[0]         = __userData[0], i
end

function GetUnitId(u) return Native.GetUnitUserData(u) end
function GetUnitById(i) return __userData[-1][i] end
function IsUnitPreplaced(u) return __userData[-2][GetUnitId(u)] end

function UnitEvent.registerCallback(eventType, func)
    if eventType > 2 or eventType < 1 then return end
    table.insert(trigTable[eventType + 2], func)
end

function UnitEvent.getEventType() return __evType end
function UnitEvent.getTriggerUnit() return __evData[1] end
function UnitEvent.getTriggerIndex() return __evData[0] end

local function __callback()
    local i = __evType + 2
    if evType == 1 then
        print('Event Type: EVENT_UNIT_ENTER')
    elseif evType == 2 then
        print('Event Type: EVENT_UNIT_LEAVE')
    end
    for _, func in pairs(trigTable[i]) do
        pcall(func)
    end
end

ceres.addHook("main::before", function()
    trigTable[0], trigTable[1], trigTable[2]    = CreateTrigger(), CreateTrigger(), CreateGroup()

    TriggerAddCondition(trigTable[0], Filter(function()
        local issuedOrder   = GetIssuedOrderId()
        local u             = GetTriggerUnit()
        --  Magic undefense
        if issuedOrder == 852479 then
            if BlzGetUnitAbility(u, DETECT_LEAVE) == nil then
                local i             = Native.GetUnitUserData(u)
                __userData[u]       = nil
                __userData[-2][i]   = nil
                __userData[-1][i]   = nil
                Native.SetUnitUserData(u, 0)

                if __initialized then
                    local l     = __evType
                    local ij    = __evData[0]
                    local jk    = __evData[1]
                    
                    __evType    = EVENT_UNIT_LEAVE
                    __evData[0] = i
                    __evData[1] = u
                    __callback()
                    __evData[1] = jk
                    __evData[0] = ij
                    __evType    = l        
                end
                __userData.dealloc(i)
            end
        end
    end))
    for i=0, bj_MAX_PLAYER_SLOTS - 1 do
        SetPlayerAbilityAvailable(players[i], DETECT_LEAVE, false)
        TriggerRegisterPlayerUnitEvent(trigTable[0], players[i], EVENT_PLAYER_UNIT_ISSUED_ORDER, nil)
    end
 
    TriggerRegisterEnterRegion(trigTable[1], World.REG, nil)
    TriggerAddCondition(trigTable[1], Filter(function()
        local u = GetTriggerUnit()

        UnitAddAbility(u, DETECT_LEAVE)
        UnitMakeAbilityPermanent(u, true, DETECT_LEAVE)
        if GetUnitId(u) == 0 then
            local i = __userData:alloc()

            Native.SetUnitUserData(u, i)
            __userData[-2][i]   = not __initialized
            __userData[-1][i]   = u
            
            if not __initialized then
                GroupAddUnit(trigTable[2], u)
            else
                local l     = __evType
                local ij    = __evData[0]
                local jk    = __evData[1]
                
                __evType    = EVENT_UNIT_ENTER
                __evData[0] = i
                __evData[1] = u
                __callback()
                __evData[1] = jk
                __evData[0] = ij
                __evType    = l
            end
        end
    end))
end)

init(function()
    local i = 0
    local j = BlzGroupGetSize(trigTable[2])
    __initialized = true
    while (i < j) do
        local u = BlzGroupUnitAt(trigTable[2], i)
        local l     = __evType
        if u ~= nil then
            local ij    = __evData[0]
            local jk    = __evData[1]

            __evType    = EVENT_UNIT_ENTER
            __evData[0] = i
            __evData[1] = u
            __callback()
            __evData[1] = jk
            __evData[0] = ij
            __evType    = l
        end
        i = i + 1
    end
end)

local __oldInitB = InitBlizzard
InitBlizzard = function()
    pcall(__oldInitB)
end