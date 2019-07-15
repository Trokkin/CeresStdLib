World               = {}
local metaWorld     = {
    __newindex      = function(t, k, v)
        k = nil
        v = nil
        return
    end,
    __metatable     = false
}

ceres.addHook("main::before", function()
    World.RECT      = GetWorldBounds()
    World.REG       = CreateRegion()
    World.MAX_X     = GetRectMaxX(World.RECT)
    World.MAX_Y     = GetRectMaxY(World.RECT)
    World.MIN_X     = GetRectMinX(World.RECT)
    World.MIN_Y     = GetRectMinY(World.RECT)
    setmetatable(World, metaWorld)
    
    RegionAddRect(World.REG, World.RECT)
end)