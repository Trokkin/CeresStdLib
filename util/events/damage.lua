require('CeresStdLib.base.basics')
require('CeresStdLib.handle.objects')

require('CeresStdLib.util.events.eventclass')

--[[
    damage.lua

    A lua library that handles damage events.

    Credits:

        Bribe for the REPO thread (without it, some interactions will have to be manually done over.)
        Link: https://www.hiveworkshop.com/threads/repo-in-progress-mapping-damage-types-to-their-abilities.316271/
]]
DMG_TYPE_PHYSICAL   = DMG_TYPE_PHYSICAL or {}
DMG_TYPE_UNIVERSAL  = DMG_TYPE_UNIVERSAL or{}
DMG_TYPE_MAGICAL    = DMG_TYPE_MAGICAL or {}

ATK_TYPE_NORMAL     = ATK_TYPE_NORMAL or {}
ATK_TYPE_MAGIC      = ATK_TYPE_MAGIC or {}
ATK_TYPE_SPELLS     = ATK_TYPE_SPELLS or {}

DamageEvent     = DamageEvent or {
    -- DEBUG_MODE      = true
    __protected     = {
        current     = {
        }
    },
    modifier        = EventClass:new(),
    normal          = EventClass:new(),
    stack           = {[0]=0, defNil={}},
    dmgtypes        = {
        __shadow        = {
            __index     = function(t, k)
                if tonumber(k) > 26 then
                    return DMG_TYPE_UNIVERSAL
                end
                return DMG_TYPE_MAGICAL
            end,
            __newindex  = function(t, k, v) end
        },

        --  Using id values instead of actual handles to circumvent handle comparison issues.
        --  Universal damage sources.
        [0]             = DMG_TYPE_UNIVERSAL,
        [26]            = DMG_TYPE_UNIVERSAL,

        --  Physical damage sources.
        [4]             = DMG_TYPE_PHYSICAL, 
        [5]             = DMG_TYPE_PHYSICAL,
        [11]            = DMG_TYPE_PHYSICAL,
        [12]            = DMG_TYPE_PHYSICAL,
        [16]            = DMG_TYPE_PHYSICAL,
        [22]            = DMG_TYPE_PHYSICAL,
        [23]            = DMG_TYPE_PHYSICAL,
    },
    atktypes        = {
        __shadow        = {
            __index     = function(t, k)
                if tonumber(k) > 6 then
                    return ATK_TYPE_MAGIC
                end
                return ATK_TYPE_NORMAL
            end,
            __newindex  = function(t, k, v) end
        },
        [0]         = ATK_TYPE_MAGIC,
        [4]         = ATK_TYPE_SPELLS,
    },
    --  onEvent with a parameter performs a set operation, whereas an onEvent without a parameter performs a get operation.
    __modify        = {
        dmg         = {
            get     = function() return GetEventDamage() end,
            set     = function(v) BlzSetEventDamage(v) end
        },
        atktype     = {
            get     = function() return AttackType.onEvent() end,
            set     = function(v) AttackType.onEvent(v) end
        },
        dmgtype     = {
            get     = function() return DamageType.onEvent() end,
            set     = function(v) DamageType.onEvent(v) end
        },
        wpntype     = {
            get     = function() return WeaponType.onEvent() end,
            set     = function(v) WeaponType.onEvent(v) end
        },
    }
}
DamageEvent.__modify.dmgclass    = {
    get     = function() return DamageEvent.dmgtypes[DamageEvent.current.dmgtype.id] end
}
DamageEvent.__modify.atkclass    = {
    get     = function() return DamageEvent.atktypes[DamageEvent.current.atktype.id] end
}
setmetatable(DamageEvent.dmgtypes, DamageEvent.dmgtypes.__shadow)
setmetatable(DamageEvent.atktypes, DamageEvent.atktypes.__shadow)

DamageEvent.__protected.current.get = function()
    if DamageEvent.stack[0] == 0 then
        return DamageEvent.stack.defNil
    end
    return DamageEvent.stack[DamageEvent.stack[0]]
end
DamageEvent.__protected.__index     = function(t, k)
    if t.__protected[k] then
        if t.__protected[k].get then
            return t.__protected[k].get()
        end
        return t.__protected[k]
    end
    local tempCur = t.current
    if tempCur[k] then
        return tempCur[k]
    end
    return nil
end
DamageEvent.__protected.__newindex  = function(t, k, v)
    if t.__protected[k] then
        return 
    end
    local tempCur = t.current
    if tempCur[k] then
        tempCur[k] = v
        return
    end
    rawset(t, k, v)
end
DamageEvent.__modify.__index     = function(t, k)
    if t.__protected[k] then
        return t.__protected[k]
    elseif DamageEvent.__modify[k].get then
        return DamageEvent.__modify[k].get()
    end
    return nil
end
DamageEvent.__modify.__newindex  = function(t, k, v)
    if DamageEvent.__modify[k].set then
        DamageEvent.__modify[k].set(v)
    end
end
setmetatable(DamageEvent, DamageEvent.__protected)

EVENT_CUSTOM_DAMAGING  = DamageEvent.modifier
EVENT_CUSTOM_DAMAGED   = DamageEvent.normal

--  Added unit extension in file.
function Unit.damageSource() return Unit.wrap(GetEventDamageSource()) end

function DamageEvent.addStack()
    local newtable  = {
        __protected     = {
            source          = Unit.damageSource(),
            target          = Unit.triggering(),    
            pureDmg         = GetEventDamage(),
            origatktype     = AttackType.onEvent(),
            origdmgtype     = DamageType.onEvent(),
            origwpntype     = WeaponType.onEvent(),
        },
    }

    setmetatable(newtable, DamageEvent.__modify)
    DamageEvent.stack[0]                    = DamageEvent.stack[0] + 1
    -- if DamageEvent.DEBUG_MODE then print('DamageEvent.stack: Stack size (+) (' .. tostring(DamageEvent.stack[0]) .. ')') end
    DamageEvent.stack[DamageEvent.stack[0] ] = newtable
end

function DamageEvent.popStack()
    local oldtable = DamageEvent.current
    setmetatable(oldtable, nil)
    oldtable.__protected    = nil
    
    DamageEvent.stack[DamageEvent.stack[0] ] = nil
    DamageEvent.stack[0]                     = DamageEvent.stack[0] - 1
    -- if DamageEvent.DEBUG_MODE then print('DamageEvent.stack: Stack size (-) (' .. tostring(DamageEvent.stack[0]) .. ')') end
end

ceres.addHook("main::before", function()
    DamageEvent.modifierTrig    = Trigger.create()
    DamageEvent.modifierTrig:registerAnyUnitEvent(EVENT_PLAYER_UNIT_DAMAGING)
    DamageEvent.modifierTrig:addCondition(function()
        DamageEvent.addStack()
        DamageEvent.modifier:listen()
        DamageEvent.current.__protected.oldDmg  = DamageEvent.current.dmg

        local typeFlags = {DamageEvent.current.target:type(UNIT_TYPE_ETHEREAL), DamageEvent.current.target:type(UNIT_TYPE_MAGIC_IMMUNE)}
        local dmgFlags  = {DamageEvent.current.dmgclass, DamageEvent.current.atkclass}

        --  Based on Sophismata's damage table.
        if dmgFlags[1] == DMG_TYPE_PHYSICAL then
            if ((dmgFlags[2] == ATK_TYPE_NORMAL) or (dmgFlags[2] == ATK_TYPE_SPELLS)) and typeFlags[1] then
                DamageEvent.popStack()
            elseif dmgFlags[2] == ATK_TYPE_MAGIC and typeFlags[2] then
                DamageEvent.popStack()
            end
        elseif dmgFlags[1] == DMG_TYPE_MAGICAL then
            if (dmgFlags[2] == ATK_TYPE_NORMAL) then 
                if typeFlags[1] or typeFlags[2] then
                    DamageEvent.popStack()
                end
            elseif typeFlags[2] then
                DamageEvent.popStack()
            end
        else
            if dmgFlags[2] == ATK_TYPE_NORMAL and typeFlags[1] then
                DamageEvent.popStack()
            elseif dmgFlags[2] == ATK_TYPE_MAGIC and typeFlags[2] then
                DamageEvent.popStack()
            end
        end
    end)

    DamageEvent.damageTrig      = Trigger.create()
    DamageEvent.damageTrig:registerAnyUnitEvent(EVENT_PLAYER_UNIT_DAMAGED)
    DamageEvent.damageTrig:addCondition(function()
        --  It is assumed that the same unit is being damaged in this thread.
        DamageEvent.current.__protected.rawDmg  = DamageEvent.current.dmg
        DamageEvent.normal:listen()
        DamageEvent.popStack()
    end)
end)

function DamageEvent.registerCallback(evType, callback) evType:register(callback) end