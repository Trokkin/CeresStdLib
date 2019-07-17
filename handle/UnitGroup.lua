require('CeresStdLib.base.Native')

UnitGroup = {}

replaceNative('GetEnumUnit', function() return UnitGroup.u end)
replaceNative('ForGroup', function(g, func)
    local i = 0
    local j = BlzGroupGetSize(g)
    local u = UnitGroup.u

    while (i < j) do
        UnitGroup.u = BlzGroupUnitAt(g, i)
        func()
        i           = i + 1
    end
    UnitGroup.u = u    
end)
