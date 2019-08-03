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

    How to register to these events:
    -> UnitEvent.registerCallback(eventType, callback)
        -> eventType is the EVENT which you will specify (EVENT_UNIT_ENTER, and EVENT_UNIT_LEAVE)
        -> callback is your function.
]]

require('CeresStdLib.base.basics')
require('CeresStdLib.handle.objects')
require('CeresStdLib.util.world')

require('CeresStdLib.util.events.eventclass')

EVENT_UNIT_ENTER        = EVENT_UNIT_ENTER or EventClass:new()
EVENT_UNIT_LEAVE        = EVENT_UNIT_LEAVE or EventClass:new()

UnitEvent               = UnitEvent or {
    RESERVED            = {
        enterTrig           = nil, 
        leaveTrig           = nil, 
        initGroup           = nil, 
        initialized         = false
    },
    DATA                = {
        triggerUnit         = nil,
        eventType           = nil
    },
    USER_DATA           = {
        preplaced           = {},
        indexed             = {},
        hasAbil             = {}
    },
}

function Unit.byId(i) return Unit.__handles[id] end
function Unit:id() return self.id end
function Unit:preplaced() return UnitEvent.USER_DATA.preplaced[self.id] end

function UnitEvent.getEventType() return UnitEvent.DATA.eventType end
function UnitEvent.getTriggerUnit() return UnitEvent.DATA.triggerUnit end
function UnitEvent.getTriggerUnitId() return UnitEvent.DATA.triggerUnit.id end

function UnitEvent.unwatch(u)
    local i     = u.id
    if u:getAbility(DETECT_LEAVE) == nil then        
        UnitEvent.USER_DATA.indexed[i]         = nil
        UnitEvent.USER_DATA[i]                 = nil
        UnitEvent.USER_DATA.preplaced[i]       = nil
        UnitEvent.USER_DATA.hasAbil[i]         = nil

        --  Only do callback if the game has already initialized.
        if UnitEvent.RESERVED.initialized then
            local l     = UnitEvent.DATA.eventType
            local ij    = UnitEvent.DATA.triggerUnit
            
            UnitEvent.DATA.eventType    = EVENT_UNIT_LEAVE
            UnitEvent.DATA.triggerUnit  = u
            UnitEvent.DATA.eventType:listen()
            UnitEvent.DATA.triggerUnit  = ij
            UnitEvent.DATA.eventType    = l
        end
        u:unwrap()
    end
end

function UnitEvent.watch(u)
    local b = u:addAbility(DETECT_LEAVE)
    local i = u.id

    if not UnitEvent.USER_DATA.indexed[i] then
        u:makeAbilityPermanent(true, DETECT_LEAVE)

        UnitEvent.USER_DATA.indexed[i]         = true
        UnitEvent.USER_DATA.preplaced[i]       = not UnitEvent.RESERVED.initialized
        UnitEvent.USER_DATA.hasAbil[i]         = not b
        
        local l     = UnitEvent.DATA.eventType
        local ij    = UnitEvent.DATA.triggerUnit

        if UnitEvent.RESERVED.initialized then                
            UnitEvent.DATA.eventType    = EVENT_UNIT_ENTER
            UnitEvent.DATA.triggerUnit  = u
            UnitEvent.DATA.eventType:listen()
            UnitEvent.DATA.triggerUnit  = ij
            UnitEvent.DATA.eventType    = l
        end
    end
end

replaceNative('CreateUnit', function(p, unitId, x, y, facing)
    local u             = Native.CreateUnit(p, unitId, x, y, facing)
    if UnitEvent.DATA.eventType == EVENT_UNIT_ENTER then
        UnitEvent.watch(Unit.wrap(u))
    end
    return u
end)

ceres.addHook("main::before", function()
    UnitEvent.RESERVED.enterTrig = Trigger.create()
    UnitEvent.RESERVED.leaveTrig = Trigger.create()

    UnitEvent.RESERVED.leaveTrig:addCondition(function()
        local issuedOrder   = GetIssuedOrderId()
        local u             = Unit.triggering()
        --  Magic undefense
        if issuedOrder == 852479 then
            UnitEvent.unwatch(u)
        end
    end)
    for i=0, bj_MAX_PLAYER_SLOTS - 1 do
        SetPlayerAbilityAvailable(players[i], DETECT_LEAVE, false)
        UnitEvent.RESERVED.leaveTrig:registerPlayerUnitEvent(players[i], EVENT_PLAYER_UNIT_ISSUED_ORDER, nil)
    end
 
    --  World.REG not wrapped up yet, as well as enterTrig
    UnitEvent.RESERVED.enterTrig:registerEnterRegion(World.REG, nil)
    UnitEvent.RESERVED.enterTrig:addCondition(function()
        UnitEvent.watch(Unit.triggering())
    end)
end)

ceres.addHook('main::after', function()
    UnitEvent.RESERVED.initialized  = true
    UnitEvent.RESERVED.initGroup    = UnitGroup.create()
    UnitEvent.RESERVED.initGroup:enumUnitsInRect(World.RECT, nil)
    UnitEvent.RESERVED.initGroup:forEach(function()
        UnitEvent.watch(UnitGroup.getEnumUnit())
    end, true)
    UnitEvent.RESERVED.initGroup:destroy()
    UnitEvent.RESERVED.initGroup    = nil
end)