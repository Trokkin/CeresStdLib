require('CeresStdLib.base.basics')
require('CeresStdLib.handle.handle')

Unit                = Handle.new()
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
Unit.__props.name   = {
                get = function(t) return GetUnitName(t.__obj) end,
                set = function(t, k) BlzSetUnitName(t.__obj, k) end
            }
Unit.__props.properName   = {
                get = function(t) return GetHeroProperName(t.__obj) end,
                set = function(t, k) BlzSetHeroProperName(t.__obj, k) end
            }
Unit.__props.typeId = {
                get = function(t) return GetUnitTypeId(t.__obj) end
            }
Unit.__tostring     = function(t)
    if t.properName ~= '' then
        return t.properName
    end
    return t.name
end
Unit.__concat       = function(a, b)
    return tostring(a) .. tostring(b)
end

function Unit.create(player, unitcode, x, y, facing) return Unit.wrap(CreateUnit(player, FourCC(unitcode), x, y, facing)) end
function Unit.createCorpse(player, unitcode, x, y, facing) return Unit.wrap(CreateCorpse(player, FourCC(unitcode), x, y, facing)) end
function Unit:remove() RemoveUnit(self.handle) self:unwrap() end

--  Ability handle not wrapped up yet
function Unit:getAbility(abilcode) return BlzGetUnitAbility(self.__obj, abilcode) end
function Unit:getAbilityLevel(abilcode) return GetUnitAbilityLevel(self.__obj, abilcode) end
function Unit:addAbility(abilcode) return UnitAddAbility(self.__obj, abilcode) end
function Unit:removeAbility(abilcode) return UnitRemoveAbility(self.__obj, abilcode) end

function Unit:makeAbilityPermanent(flag, abilcode) return UnitMakeAbilityPermanent(self.__obj, flag, abilcode) end

function Unit.triggering() return Unit.wrap(GetTriggerUnit()) end