Handle = {__metatable = false}

Handle.copy            = function()
    local obj          = {
        __handles   = {},
        __props     = {
            id			= {
                ids     = {}
            },
            handle      = {
                get     = function(t) return t.__obj end
            }
        },
    }
    obj.__props.id.get  = function(t)
        if not obj.__props.id.ids[t] then obj.__props.id.ids[t] = GetHandleId(t.__obj) end 
        return obj.__props.id.ids[t]
    end
    --  No matter which value you give to v, set will only make it 0.
    obj.__props.id.set  = function(t, v) obj.__props.id.ids[t] = nil end
    return obj
end

Handle.getIndexFactory = function(meta)
    local f = function(t, k)
        if meta.__props[k] then
            if meta.__props[k].get then
                return meta.__props[k].get(t)
            end
            return meta.__props[k][t]
        end
        local metaHas = rawget(meta, k)
        if metaHas ~= nil then
            return metaHas
        end
        return rawget(t, k)
    end
    return f
end

Handle.setIndexFactory = function(meta)
    local f = function(t, k, v)
        if meta.__props[k] then
            if meta.__props[k].set then
                meta.__props[k].set(t, v)
                return
            end
            meta.__props[k][t] = v
            return
        end
        local metaHas = rawget(meta, k)
        if metaHas ~= nil then
            return
        end
        rawset(t, k, v)
    end
    return f
end

Handle.wrapFactory      = function(meta)
    local f = function(handle)
        local i = GetHandleId(handle)
        if i == 0 then
            return nil
        end
        if not meta.__handles[i] then
            meta.__handles[i]                       = {__obj = handle}
            setmetatable(meta.__handles[i], meta)
            local j = meta.__handles[i].id
        end
        return meta.__handles[i]
    end
    return f
end

Handle.unwrapFactory    = function(meta)
    function meta:unwrap()
        if meta.__handles[self.id] ~= nil then
            local i                     = self.id
            self.id                     = nil
            meta.__handles[i].__mode    = 'kv'
            meta.__handles[i]           = nil
        end
    end
end

function Handle:new()
    local obj       = self.copy()
    obj.__index     = self.getIndexFactory(obj)
    obj.__newindex  = self.setIndexFactory(obj)
    obj.wrap        = self.wrapFactory(obj)
    obj.__eq        = function(a, b)
        return (obj.__props.id.ids[a] == obj.__props.id.ids[b]) and ((getmetatable(a) == getmetatable(b)) and (getmetatable(a) == obj))
    end
    
    self.unwrapFactory(obj)
    setmetatable(obj, self)
    return obj
end
