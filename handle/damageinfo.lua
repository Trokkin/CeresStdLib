require('CeresStdLib.handle.handle')
require('CeresStdLib.base.basics')

AttackType = AttackType or Handle.new()
DamageType = DamageType or Handle.new()
WeaponType = WeaponType or Handle.new()

AttackType.doReplacement = false
DamageType.doReplacement = false
WeaponType.doReplacement = false

--  Defining additional properties of each handle type.
--  Name, for example.
if not AttackType.__props.name then
    AttackType.__props.name = {
        __ids = {},
    }
    AttackType.__props.name.get = function(t) return AttackType.__props.name.__ids[t] end
    AttackType.__props.name.set = function(t, v) AttackType.__props.name.__ids[t] = v end
end

DamageType.__props.name = {
    __ids = {},
}
DamageType.__props.name.get = function(t) return DamageType.__props.name.__ids[t] end
DamageType.__props.name.set = function(t, v) DamageType.__props.name.__ids[t] = v end

WeaponType.__props.name = {
    __ids = {},
}
WeaponType.__props.name.get = function(t) return WeaponType.__props.name.__ids[t] end
WeaponType.__props.name.set = function(t, v) WeaponType.__props.name.__ids[t] = v end

--  Starting here, getmetatable will be used for readability purposes (when referring to a metamethod)
--  Leave that to AttackType's metatable.
--  @ param k is expected as an integer.
getmetatable(AttackType).__call = function(k)
    k = tonumber(k) or 0
    return AttackType.wrap(ConvertAttackType(k), true)
end

getmetatable(DamageType).__call = function(k)
    k = tonumber(k) or 0
    return DamageType.wrap(ConvertDamageType(k), true)
end

getmetatable(WeaponType).__call = function(k)
    k = tonumber(k) or 0
    return WeaponType.wrap(ConvertWeaponType(k), true)
end

ceres.addHook("main::before", function()
    for k, v in pairs(_G) do
        if k:len() > 13 then
            local sub   = k:sub(1, 11)
            local esub = k:sub(13)
            if sub == 'ATTACK_TYPE' or sub == 'DAMAGE_TYPE' or sub == 'WEAPON_TYPE' then
                if sub == 'ATTACK_TYPE' then
                    local atk           = AttackType.wrap(v, true)
                    atk.name            = k
                    AttackType[esub]    = atk
                elseif sub == 'DAMAGE_TYPE' then
                    local dmg           = DamageType.wrap(v, true)
                    dmg.name            = k
                    DamageType[esub]    = dmg
                else
                    local wpn           = WeaponType.wrap(v, true)
                    wpn.name            = k
                    WeaponType[esub]    = wpn
                end
            end
        end
    end
    --  Prevent external assignments.
    AttackType.__props.name.set = nil
    DamageType.__props.name.set = nil
    WeaponType.__props.name.set = nil
end)

function AttackType.onEvent(...)
    local paramcount = table.pack(...)
    if paramcount.n == 0 then
        return AttackType.wrap(BlzGetEventAttackType(), true) or AttackType.NORMAL
    end
    BlzSetEventAttackType(paramcount[1].__obj)
end
function DamageType.onEvent(...)
    local paramcount = table.pack(...)
    if paramcount.n == 0 then
        return DamageType.wrap(BlzGetEventDamageType(), true) or DamageType.UNKNOWN
    end
    BlzSetEventDamageType(paramcount[1].__obj)
end
function WeaponType.onEvent(...)
    local paramcount = table.pack(...)
    if paramcount.n == 0 then
        return WeaponType.wrap(BlzGetEventWeaponType(), true) or WeaponType.NORMAL
    end
    BlzSetEventWeaponType(paramcount[1].__obj)
end