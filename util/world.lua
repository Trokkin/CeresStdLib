require('CeresStdLib.base.basics')
require('CeresStdLib.handle.objects')

--  Za Warudo should be empty.
local metaWorld     = {}
World               = makeReadonly(metaWorld, 'World')

ceres.addHook("main::before", function()
    metaWorld.RECT      = rect.worldBounds()
    metaWorld.REG       = CreateRegion()

    metaWorld.MAX_X     = metaWorld.RECT.maxX
    metaWorld.MAX_Y     = metaWorld.RECT.maxY
    metaWorld.MIN_X     = metaWorld.RECT.minX
    metaWorld.MIN_Y     = metaWorld.RECT.minY

    RegionAddRect(World.REG, World.RECT.__obj)
end)
