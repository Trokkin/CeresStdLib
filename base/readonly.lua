require('CeresStdLib.base.log')

NOT_VALID       = {}
META_TABLE      = {
    __TABLES    = {},
    __NAMES     = {},
}

function makeReadonly(table, name)
    if META_TABLE.__TABLES[table] then return META_TABLE.__TABLES[table] end
    name                            = name or 'nil'

    local proxy                     = {}
    META_TABLE.__TABLES[table]      = proxy

    local result                    = false
    META_TABLE.__NAMES[proxy]       = name

    setmetatable(proxy, {
        __index     = function(t, k) return table[k] end,
        __newindex  = function(t, k, v)
            if name ~= 'nil' then 
                Log.warn(name .. ': Intercepted an assignment to key ' .. k) 
            else 
                Log.warn('Intercepted an assignment to key ' .. k .. ' in readonly table.') 
            end
        end,
        __metatable = false
    })
    return proxy
end