require('CeresStdLib.base.basics')
require('CeresStdLib.handle.handle')

UnitGroup               = Handle:new()
UnitGroup.__props.count = {
                    get = function (t) return BlzGroupGetSize(t.__obj) end
                    }

function UnitGroup.create() return UnitGroup.wrap(CreateGroup()) end
function UnitGroup:destroy() DestroyGroup(self.__obj) self:unwrap() end

--  Not wrapped up yet.
function UnitGroup.getEnumUnit() return GetEnumUnit() end

function UnitGroup:unit(index) return BlzGroupUnitAt(self.__obj, index) end
--  Not wrapped up yet.
function UnitGroup:first() return FirstOfGroup(self.__obj) end
--  Not wrapped up yet.
function UnitGroup:last() return self:unit(self.count - 1) end
--  Not wrapped up yet.
function UnitGroup:add(u) return GroupUnitAdd(self.__obj, u) end
--  Not wrapped up yet.
function UnitGroup:remove(u) return GroupUnitRemove(self.__obj, u) end

function UnitGroup:clear() GroupClear(self.__obj) end
function UnitGroup:enumUnitsInRange(x, y, range, filter) GroupEnumUnitsInRange(self.__obj, x, y, range, filter) end
