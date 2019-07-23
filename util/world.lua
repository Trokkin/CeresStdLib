require('CeresStdLib.base.basics')
require('CeresStdLib.handle.objects')

--  The world should be
META_WORLD          = META_WORLD or {}
World               = makeReadonly(META_WORLD, 'World')

ceres.addHook("main::before", function()
    META_WORLD.RECT      = rect.worldBounds()
    META_WORLD.REG       = CreateRegion()

    META_WORLD.MAX_X     = META_WORLD.RECT.maxX
    META_WORLD.MAX_Y     = META_WORLD.RECT.maxY
    META_WORLD.MIN_X     = META_WORLD.RECT.minX
    META_WORLD.MIN_Y     = META_WORLD.RECT.minY

    RegionAddRect(World.REG, World.RECT.__obj)
end)
