Handle = {}

Handle.__index = function(t, k)
    if t.__properties[k] then
        return t.__properties[k]
    elseif t.__props[k] then
        return t.__props[k]
    end
    return rawget(t, k)
end