require('CeresStdLib.base.Basics')
require('CeresStdLib.handle.handle')

Unit                = Handle:new()
Unit.__props.x      = {
                get = function(t) return GetUnitX(t.__obj) end,
                set = function(t, x) SetUnitX(t.__obj, x) end
            }
Unit.__props.y      = {
                get = function(t) return GetUnitY(t.__obj) end,
                set = function(t, y) SetUnitY(t.__obj, y) end
            }
Unit.__props.z      = {
                get = function(t) return BlzGetUnitZ(t.__obj) end,
                set = function(t, z)
                    local groundZ = BlzGetUnitZ(t.__obj) - GetUnitFlyHeight(t.__obj)
                    SetUnitFlyHeight(t.__obj, z - groundZ, 0.)
                end
            }
Unit.__props.height = {
                get = function(t) return GetUnitFlyHeight(t.__obj) end,
                set = function(t, height)
                    if not IsUnitType(t.__obj, UNIT_TYPE_FLYING) then
                        if UnitAddAbility(t.__obj, HEIGHT_ENABLER) then UnitRemoveAbility(t.__obj, HEIGHT_ENABLER) end
                    end
                    SetUnitFlyHeight(t.__obj, height, 0.)
                end
            }

function Unit.create(player, unitcode, x, y, facing) return Unit.wrap(CreateUnit(player, FourCC(unitcode), x, y, facing)) end
function Unit.createCorpse(player, unitcode, x, y, facing) return Unit.wrap(CreateCorpse(player, FourCC(unitcode), x, y, facing)) end
function unit:remove()
    local u = self.__obj
    self:unwrap()
    RemoveUnit(u)
end
