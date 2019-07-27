require('CeresStdLib.base.basics')

EventClass              = EventClass or {}
EventClass.__index      = function(t, k)
    --  Child is prioritized over parent
    local childRes      = rawget(t, k)
    if childRes ~= nil then
        return childRes
    end
    return EventClass[k]
end

function EventClass:copy()
    local copy      = {
        __shadow    = {
            __level     = 0,
            __maxlevel  = -1,
            __callList  = {
                __flags     = {},
                __count     = {},
                __list      = {}
            },
            __hotList   = {
                __maxiters  = -1,
                __iters     = {},
                __funcs     = {},
                __cur       = {}
            },
            __rmvList   = {}
        }
    }
    copy.__index                = function(t, k)
        --  Child is prioritized over parent
        local childRes      = rawget(t, k)
        if childRes ~= nil then
            return childRes
        end
        return copy[k]
    end
    copy.__shadow.__index       = function(t, k)
        return copy.__shadow[k]
    end
    copy.__shadow.__newindex    = function(t, k, v)
        copy.__shadow[k]        = v
    end
    setmetatable(copy.__shadow, self)
    setmetatable(copy, copy.__shadow)
    return copy
end

function EventClass:new(o)
    o = self:copy()
    setmetatable(o.__shadow, EventClass)
    return o
end

--  @ Registers a callback function to the EventClass object.
--  @ If that function is already registered, increment the number of times it will be called.
--  @ param callback is a function
function EventClass:register(callback)
    if self.__callList.__flags[callback] == nil then
        self.__callList.__flags[callback] = true
        self.__callList.__count[callback] = 1
        table.insert(self.__callList.__list, callback)
    else
        self.__callList.__count[callback] = self.__callList.__count[callback] + 1
    end
    return true
end

--  @ Removes a callback function from the EventClass object if it has only been registered once.
--  @ Otherwise, decrements the number of times it will be called.
--  @ Handles a special case when functions are being unregistered during callbacks.
--  @ param callback is a function
function EventClass:unregister(callback)
    -- if --[[(type(callback) ~= 'function') or]] (not self.__callList.__flags[callback]) then return false end
    if self.__level > 0 then
        if not self.__rmvList[callback] then
            self.__rmvList[callback] = 1
        else
            self.__rmvList[callback] = self.__rmvList[callback] + 1
        end
        return self.__callList.__count[callback] > self.__rmvList[callback]
    end
    if self.__rmvList[callback] then
        self.__callList.__count[callback]   = self.__callList.__count[callback] - self.__rmvList[callback]
        self.__rmvList[callback]            = nil
    else
        self.__callList.__count[callback]   = self.__callList.__count[callback] - 1
    end
    if self.__callList.__count[callback] <= 0 then
        self.__callList.__flags[callback] = nil
        self.__callList.__count[callback] = nil
        table.remove(self.__callList.__list, callback)
    end
    return self.__callList.__count[callback] == nil
end

--  @ The main callback function execution.
--  @ It will detect if any function causes a recursion and will flag it as a hot function 
--  @ after a specified number of executions.
--  @ This will only apply when __maxiters (maximum number of recursions per function) has been reached.
function EventClass:onThrowEvent(func)
    if self.__hotList.__maxiters > 0 then
        if self.__hotList.__cur[self.__level] == self.__hotList.__cur[self.__level - 1] then
            if self.__hotList.__iters[func] == nil then
                self.__hotList.__iters[func]    = 1
            else
                self.__hotList.__iters[func]    = math.max(self.__hotList.__iters[func] + 1, self.__hotList.__maxiters)
            end
            self.__hotList.__funcs[func]    = (self.__hotList.__iters[func] == self.__hotList.__maxiters)
        end
    end
    if not self.__hotList.__funcs[func] and ((not self.__rmvList[func]) or (self.__rmvList[func] == 0)) then
        execute(func)
    end
end

--  @ param newf refers to your function (must have two arguments, table and function)
--  @ syntactic sugar for self.onThrowEvent = newf
function EventClass:defThrowEvent(newf)
    newf = newf or EventClass.onThrowEvent
    if newf == EventClass.onThrowEvent then
        self.onThrowEvent = nil 
    else 
        self.onThrowEvent = newf
    end
end

--  @ param i defines maximum number of iterations (anything less than or equal to 0 is virtually infinite.)
--  @ i (int)
function EventClass:defMaxRecursion(i)
    self.__maxlevel     = math.max(i, -1)
end

--  @ param i defines maximum number of iterations for each function (anything less than or equal to 0 is virtually infinite.)
--  @ This is separate from __maxlevel.
--  @ i (int)
function EventClass:defLocalMaxRecursion(i)
    if self.__maxlevel <= 0 then self.__hotList.__maxiters = math.max(i, self.__maxlevel) else self.__hotList.__maxiters = math.min(math.max(i, 1), self.__maxlevel) end
end

function EventClass:listen(i)
    self.__level = self.__level + 1
    if self.__maxlevel > 0 and (self.__level <= self.__maxlevel) or (self.__maxlevel <= 0) then
        for k, v in pairs(self.__callList.__list) do
            i = self.__callList.__count[v]
            self.__hotList.__cur[self.__level] = v
            while (i > 0) do
                i = i - 1
                self:onThrowEvent(v)    
                if self.__level <= 1 then
                    self.__hotList.__funcs[v] = nil
                    self.__hotList.__iters[v] = nil
                end
            end
        end
    end
    self.__level = self.__level - 1
    if self.__level ~= 0 then return end
    for k, v in pairs(self.__rmvList) do
        self:unregister(k)
    end
end