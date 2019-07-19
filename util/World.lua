require('CeresStdLib.base.basics')

--  Za Warudo should be empty.
local metaWorld     = {}
World               = makeReadonly(metaWorld, 'World')

ceres.addHook("main::before", function()
    metaWorld.RECT      = GetWorldBounds()
    metaWorld.REG       = CreateRegion()
    metaWorld.MAX_X     = GetRectMaxX(metaWorld.RECT)
    metaWorld.MAX_Y     = GetRectMaxY(metaWorld.RECT)
    metaWorld.MIN_X     = GetRectMinX(metaWorld.RECT)
    metaWorld.MIN_Y     = GetRectMinY(metaWorld.RECT)

    RegionAddRect(World.REG, World.RECT)
end)
