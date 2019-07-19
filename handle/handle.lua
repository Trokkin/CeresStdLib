Handle = {}

Handle.__index = function(t, k)
    if t.__properties[k] then
        return t.__properties[k]
    end
end

TimerEx = {}
setmetatable(TimerEx, Handle)
