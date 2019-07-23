require('CeresStdLib.base.basics')

EventClass              = EventClass or {}
EventClass.__index      = function(t, k)
    return rawget(EventClass, k)
end
EventClass.__newindex   = function(t, k, v)
end

EventClass.copy         = function()
    local copy      = {
        __callbacks = {},
        __forcalls  = {},
        __curcalls  = {},
        __rmvstack  = {},
        __level     = 0,
        __maxlevel  = 2
    }
    return copy
end

function EventClass:new(o)
    o = o or self.copy()
    setmetatable(o, self)
    return o
end

--  @ param callback refers to a callback function
function EventClass:register(callback)
    if not self.__callbacks[callback] then
        self.__callbacks[callback]  = true
        table.insert(self.__forcalls, callback)
        return true
    end
    return false
end
--  @ param callback refers to a callback function
function EventClass:unregister(callback)
    if not self.__callbacks[callback] then return false end
    if (self.__level > 0) and (not self.__rmvstack[callback]) then
        self.__rmvstack[callback]       = true
        return true
    elseif (self.__level == 0) then
        if self.__rmvstack[callback] then
            self.__rmvstack[callback]   = false
        end
        self.__callbacks[callback]      = nil
        table.remove(self.__forcalls, callback)
        return true
    end
    return false
end

--  Iterates through a list of callback functions, then removes all callback functions
--  that have been marked for removal. Will not allow a recursion level below
--  a specified __maxlevel.
function EventClass:listen()
    self.__level = self.__level + 1
    for _, v in pairs(self.__forcalls) do
        self.__curcalls[self.__level] = v
        if (self.__curcalls[self.__level] ~= self.__curcalls[self.__level - 1]) or (self.__level < self.__maxlevel) then
            execute(v)
        end
    end
    self.__level = self.__level - 1
    if self.__level > 0 then return end
    for k, _ in pairs(self.__rmvstack) do
        self:unregister(k)
    end
end