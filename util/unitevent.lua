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
require('CeresStdLib.util.listener')

EVENT_UNIT_ENTER        = EVENT_UNIT_ENTER or {}
EVENT_UNIT_LEAVE        = EVENT_UNIT_LEAVE or {}

UnitEvent               = UnitEvent or {}
UnitEvent.VALID_VALUES  = UnitEvent.VALID_VALUES or {}
UnitEvent.RESERVED      = UnitEvent.RESERVED or {enterTrig=nil, leaveTrig=nil, initGroup=nil, initialized=false}
UnitEvent.DATA          = UnitEvent.DATA or {triggerUnit=nil, eventType=nil}
UnitEvent.USER_DATA     = UnitEvent.USER_DATA or {}

UnitEvent.VALID_VALUES[EVENT_UNIT_ENTER]    = UnitEvent.VALID_VALUES[EVENT_UNIT_ENTER] or EventClass:new()
UnitEvent.VALID_VALUES[EVENT_UNIT_LEAVE]    = UnitEvent.VALID_VALUES[EVENT_UNIT_LEAVE] or EventClass:new()
UnitEvent.USER_DATA.preplaced               = UnitEvent.USER_DATA.preplaced or {}
UnitEvent.USER_DATA.indexed                 = UnitEvent.USER_DATA.indexed or {}
UnitEvent.USER_DATA.hasAbil                 = UnitEvent.USER_DATA.hasAbil or {}

function Unit.byId(i) return Unit.__handles[id] end
function Unit:id() return self.id end
function Unit:preplaced() return UnitEvent.USER_DATA.preplaced[self.id] end
function UnitEvent.registerCallback(eventType, func) UnitEvent.VALID_VALUES[eventType]:register(func) end

function UnitEvent.getEventType() return UnitEvent.DATA.eventType end
function UnitEvent.getTriggerUnit() return UnitEvent.DATA.triggerUnit end
function UnitEvent.getTriggerUnitId() return UnitEvent.DATA.triggerUnit.id end

ceres.addHook("main::before", function()
    UnitEvent.RESERVED.enterTrig = CreateTrigger()
    UnitEvent.RESERVED.leaveTrig = CreateTrigger()

    TriggerAddCondition(UnitEvent.RESERVED.leaveTrig, Filter(function()
        local issuedOrder   = GetIssuedOrderId()
        local u             = Unit.triggering()
        --  Magic undefense
        if issuedOrder == 852479 then
            if u:getAbility(DETECT_LEAVE) == nil then
                local i     = u.id
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
                    UnitEvent.VALID_VALUES[UnitEvent.DATA.eventType]:listen()
                    UnitEvent.DATA.triggerUnit  = ij
                    UnitEvent.DATA.eventType    = l
                end
                u:unwrap()
            end
        end
    end))
    for i=0, bj_MAX_PLAYER_SLOTS - 1 do
        SetPlayerAbilityAvailable(players[i], DETECT_LEAVE, false)
        TriggerRegisterPlayerUnitEvent(UnitEvent.RESERVED.leaveTrig, players[i], EVENT_PLAYER_UNIT_ISSUED_ORDER, nil)
    end
 
    --  World.REG not wrapped up yet, as well as enterTrig
    TriggerRegisterEnterRegion(UnitEvent.RESERVED.enterTrig, World.REG, nil)
    TriggerAddCondition(UnitEvent.RESERVED.enterTrig, Filter(function()
        local u = Unit.triggering()
        local b = u:addAbility(DETECT_LEAVE)
        local i = u.id

        u:makeAbilityPermanent(true, DETECT_LEAVE)
        if not UnitEvent.USER_DATA.indexed[i] then
            UnitEvent.USER_DATA.indexed[i]         = true
            UnitEvent.USER_DATA.preplaced[i]       = not UnitEvent.RESERVED.initialized
            UnitEvent.USER_DATA.hasAbil[i]         = not b
            
            local l     = UnitEvent.DATA.eventType
            local ij    = UnitEvent.DATA.triggerUnit

            if UnitEvent.RESERVED.initialized then                
                UnitEvent.DATA.eventType    = EVENT_UNIT_ENTER
                UnitEvent.DATA.triggerUnit  = u
                UnitEvent.VALID_VALUES[UnitEvent.DATA.eventType]:listen()
                UnitEvent.DATA.triggerUnit  = ij
                UnitEvent.DATA.eventType    = l
            end
        end
    end))
end)

ceres.addHook('main::after', function()
    UnitEvent.RESERVED.initGroup = UnitGroup.create()
    UnitEvent.RESERVED.initGroup:enumUnitsInRect(World.RECT, nil)
    UnitEvent.RESERVED.initGroup:forEach(function()
        local u = UnitGroup.getEnumUnit()
        local i = u.id

        if not UnitEvent.USER_DATA.indexed[i] then
            UnitEvent.USER_DATA.indexed[i]         = true
            UnitEvent.USER_DATA.preplaced[i]       = true
            UnitEvent.USER_DATA.hasAbil[i]         = not u:addAbility(DETECT_LEAVE)
            
            local l     = UnitEvent.DATA.eventType
            local ij    = UnitEvent.DATA.triggerUnit
            
            UnitEvent.DATA.eventType    = EVENT_UNIT_ENTER
            UnitEvent.DATA.triggerUnit  = u
            UnitEvent.VALID_VALUES[UnitEvent.DATA.eventType]:listen()
            UnitEvent.DATA.triggerUnit  = ij
            UnitEvent.DATA.eventType    = l
        end
    end, true)
    UnitEvent.RESERVED.initGroup:destroy()
    UnitEvent.RESERVED.initGroup        = nil
    UnitEvent.RESERVED.initialized      = true
end)

function foo()
    print('A unit ' .. UnitEvent.getTriggerUnit() .. ' has entered the game.')
end
UnitEvent.registerCallback(EVENT_UNIT_ENTER, foo)
UnitEvent.registerCallback(EVENT_UNIT_ENTER, foo)
UnitEvent.registerCallback(EVENT_UNIT_LEAVE, function()
    print('A unit ' .. UnitEvent.getTriggerUnit() .. ' has left the game.')
end)