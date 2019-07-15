require('CeresStdLib.base.Native')

local __u = u

replaceNative('GetEnumUnit', function() return __u end)
replaceNative('ForGroup', function(g, func)
    local i = 0
    local j = BlzGroupGetSize(g)
    local u = __u

    while (i < j) do
        __u     = BlzGroupUnitAt(g, i)
        func()
        i       = i + 1
    end
    __u     = u    
end)
