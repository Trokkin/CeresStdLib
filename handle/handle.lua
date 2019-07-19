Handle = {__metatable = false}

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
            print('Metatable has attribute ' .. k)
            return metaHas
        end
        print('Only table has attribute ' .. k)
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
            print('Setting metatable attribute ' .. k)
            rawset(meta, k, v)
            return
        end
        print('Setting table attribute ' .. k)
        rawset(t, k, v)
    end
    return f
end

Handle.wrapFactory      = function(meta)
    local f = function(handle)
        local i = GetHandleId(handle)
        if not meta.__handles[i] then
            meta.__handles[i] = {__obj = handle}
            setmetatable(meta.__handles[i], meta)
        end
        return meta.__handles[i]
    end
    return f
end

Handle.unwrapFactory    = function(meta)
    function meta:unwrap()
        meta.__handles[self.id].__mode  = 'kv'
        meta.__handles[self.id]         = nil
        print('Unwrapped!')
    end
end

function Handle:new()
    local obj   = {
        __handles   = {},
        __props     = {
            id			= {
                get		= function(t) return GetHandleId(t.__obj) end
            },
            handle      = {
                get     = function(t) return t.__obj end
            }
        }
    }
    obj.__index     = self.getIndexFactory(obj)
    obj.__newindex  = self.setIndexFactory(obj)
    obj.wrap        = self.wrapFactory(obj)
    
    self.unwrapFactory(obj)
    setmetatable(obj, self)
    return obj
end