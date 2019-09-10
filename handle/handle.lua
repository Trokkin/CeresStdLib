require('CeresStdLib.base.properties')
Handle = {__metatable = false}

Handle.copy            = function()
    local obj          = enableProperties{
        __shadow            = {},
        __handles           = {},
        __ids = {}
    }
    obj.__props.handle              = {
        get                 = function(t) return t.__obj end
    }
    obj.__props.id = {
        get = function(t)
            if not obj.__ids[t] then obj.__ids[t] = GetHandleId(t.__obj) end
            return obj.__ids[t]
        end,
        set = function(t, v) obj.__ids[t] = nil end
    }
    return obj
end

function Handle.new()
    local obj = Handle.copy()
    obj.__props.field = { get = function() return 'lol' end}
    obj.wrap = function(handle, override)
        local i = GetHandleId(handle)
        if i == 0 and not override then
            return nil
        end
        if not obj.__handles[i] then
            obj.__handles[i]   = {__obj = handle}
            setmetatable(obj.__handles[i], obj)
            local j = obj.__handles[i].id
        end
        return obj.__handles[i]
    end
    obj.unwrap = function(self)
        if obj.__handles[self.id] ~= nil then
            local i                     = self.id
            self.id                     = nil
            -- obj.__handles[i].__mode    = 'kv'
            obj.__handles[i]           = nil
        end
    end
    obj.__eq = function(a, b)
        return (obj.__ids[a] == obj.__ids[b]) and ((getmetatable(a) == getmetatable(b)) and (getmetatable(a) == obj))
    end
    
    setmetatable(obj, obj.__shadow)
    return obj
end