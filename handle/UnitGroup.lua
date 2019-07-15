require('CeresStdLib.base.Native')

local __u

local function tempEnumUnit()
    return __u
end

replaceNative('GetEnumUnit', tempEnumUnit)
replaceNative('ForGroup', function(g, func)
    local i = 0
    local j = BlzGroupGetSize(g)
    local u = __u

    while (i < j) do
        __u = BlzGroupUnitAt(g, i)
        pcall(func)
        i = i + 1
    end
    __u     = u    
end)