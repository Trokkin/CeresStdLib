require('CeresStdLib.util.events.damage')

DamageEvent.__protected.previous        = DamageEvent.__protected.previous or {}
DamageEvent.__protected.previous.get    = function(t, k)
    if DamageEvent.stack[0] - 1 <= 0 then
        return DamageEvent.stack.defNil
    end
    return DamageEvent.stack[DamageEvent.stack[0] - 1]
end

DamageEvent.registerCallback(EVENT_CUSTOM_DAMAGING, function() DamageEvent.current.__protected.linkDmg = 0 end)

DamageEvent.registerCallback(EVENT_CUSTOM_DAMAGED, function()
    if DamageEvent.dmgtype == DamageType.SPIRIT_LINK then
        -- DamageEvent.dmg = 0.
        if DamageEvent.previous ~= nil then
            DamageEvent.previous.__protected.linkDmg = DamageEvent.previous.__protected.linkDmg + DamageEvent.current.pureDmg
            DamageEvent.previous.__protected.oldDmg  = DamageEvent.previous.__protected.oldDmg - DamageEvent.current.pureDmg
        end
    end
end)