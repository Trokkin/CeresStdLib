local META_TABLE    = {
    TABLES          = {},
    METATABLES      = {},
    NAME            = {},
    __metatable     = false
}
META_TABLE.__index      = function(t, k)
    return META_TABLE.METATABLES[t][k]
end
META_TABLE.__newindex   = function(t, k, v)
    Log.warn('Attempted to assign value ' .. tostring(v) .. ' to key ' .. k .. ' in readonly table ' .. (META_TABLE.NAME[t] or '') .. '.') 
end

function makeReadonly(table, name)
    -- local lastMetatable     = getmetatable(table)    
    --  If the table is already readonly, return the proxy table
    if META_TABLE.TABLES[table] then return META_TABLE.TABLES[table] end
    
    local proxy                     = {}
    META_TABLE.METATABLES[proxy]    = table
    META_TABLE.TABLES[table]        = proxy

    if name then META_TABLE.NAME[proxy] = name end
    
    setmetatable(proxy, META_TABLE)
    return proxy
end