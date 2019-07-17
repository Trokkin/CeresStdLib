--[[
    UnitEvent (Namesake)
        Originally by Bribe

    Uses Magic Defense instead of Defend ability to detect leave.
    How it works:

    -> A unit is created
        -> Fires a unit creation event (via proxy Unit Enters Region event)
        -> The magic defense ability is added to the unit if not already present.
        -> A new index is generated for that unit.

    -> A unit is removed
        -> When the magic defense ability is removed, unit issues the order 852479.
        -> If the ability was removed, mark the unit as removed.
]]

require('CeresStdLib.base.Basics')

require('CeresStdLib.handle.UnitGroup')
require('CeresStdLib.util.World')

EVENT_UNIT_ENTER        = 1
EVENT_UNIT_LEAVE        = 2

UnitEvent = {}

local trigTable         = {}
local userData          = {}

userData.preplaced      = {}   --  Holds references to each unit
userData.unitId         = {}   --  Holds preplaced flag
userData.nativeHasAbil  = {}   --  Holds a flag telling the system if the unit already has that ability.
userData.indexed        = {}

trigTable[0]            = CreateTrigger()
trigTable[1]            = CreateTrigger()
trigTable[2]            = CreateGroup()
trigTable[3]            = {}
trigTable[4]            = {}

local evType            = 0
local evData            = nil
local initialized       = false

function GetUnitId(u) return GetHandleId(u) end
function GetUnitById(i) return userData.unitId[i] end
function IsUnitPreplaced(u) return userData.preplaced[GetHandleId(u)] end

function UnitEvent.registerCallback(eventType, func)
    if eventType > 2 or eventType < 1 then return end
    table.insert(trigTable[eventType + 2], func)
end

function UnitEvent.getEventType() return evType end
function UnitEvent.getTriggerUnit() return evData end
function UnitEvent.getTriggerUnitId() return GetHandleId(evData) end

local function callback()
    local i = evType + 2
    for _, func in pairs(trigTable[i]) do
        pcall(func)
    end
end

ceres.addHook("main::before", function()
    TriggerAddCondition(trigTable[0], Filter(function()
        local issuedOrder   = GetIssuedOrderId()
        local u             = GetTriggerUnit()
        --  Magic undefense
        if issuedOrder == 852479 then
            if BlzGetUnitAbility(u, DETECT_LEAVE) == nil then
                local i     = GetHandleId(u)
                if GetUnitTypeId(u) == 0 then
                    userData.indexed[i]         = nil
                    userData[i]                 = nil
                    userData.preplaced[i]       = nil
                    userData.unitId[i]          = nil
                    userData.nativeHasAbil[i]   = nil

                    --  Only do callback if the game has already initialized.
                    if initialized then
                        local l     = evType
                        local ij    = evData
                        
                        evType      = EVENT_UNIT_LEAVE
                        evData      = u
                        callback()
                        evData      = ij
                        evType      = l        
                    end
                    userData.dealloc(i)
                end
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
        local b = UnitAddAbility(u, DETECT_LEAVE)
        local i = GetHandleId(u)

        UnitMakeAbilityPermanent(u, true, DETECT_LEAVE)
        if not userData.indexed[i] then
            userData.indexed[i]         = true
            userData.preplaced[i]       = not initialized
            userData.unitId[i]          = u
            userData.nativeHasAbil[i]   = not b
            
            local l     = evType
            local ij    = evData

            if initialized then
                evType      = EVENT_UNIT_ENTER
                evData      = u
                callback()
                evData      = ij
                evType      = l
            end
        end
    end))
end)

ceres.addHook('main::after', function()
    GroupEnumUnitsInRect(trigTable[2], World.RECT, nil)
    ForGroup(trigTable[2], function()
        local u = GetEnumUnit()
        local i = GetHandleId(u)
        
        if not userData.indexed[i] then
            userData.indexed[i]         = true
            userData.preplaced[i]       = not initialized
            userData.unitId[i]          = u
            userData.nativeHasAbil[i]   = not UnitAddAbility(u, DETECT_LEAVE)
            
            local l     = evType
            local ij    = evData

            evType      = EVENT_UNIT_ENTER
            evData      = u
            callback()
            evData      = ij
            evType      = l
        end
    end)
    DestroyGroup(trigTable[2])
    trigTable[2]    = nil
    initialized     = true
end)
