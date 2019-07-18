require('CeresStdLib.base.Basics')

local uG    = {}
UnitGroup   = makeReadonly(uG, 'Unit Group')

replaceNative('GetEnumUnit', function() return UnitGroup.u end)
replaceNative('ForGroup', function(g, func)
    local i = 0
    local j = BlzGroupGetSize(g)
    local u = uG.u

    while (i < j) do
        uG.u = BlzGroupUnitAt(g, i)
        func()
        i           = i + 1
    end
    uG.u = u    
end)
