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

--  Wrapped in the UnitGroup class
function UnitGroup:remove(u) return GroupUnitRemove(self.__obj, u) end
function UnitGroup:addGroup(g) return BlzGroupAddGroupFast(self.__obj, g.__obj) end
function UnitGroup:removeGroup(g) return BlzGroupRemoveGroupFast(self.__obj, g.__obj) end

function UnitGroup:clear() GroupClear(self.__obj) end
function UnitGroup:enumUnitsOfPlayer(p, filter) GroupEnumUnitsOfPlayer(p, filter) end
function UnitGroup:enumUnitsSelected(p, filter) GroupEnumUnitsSelected(p, filter) end

function UnitGroup:enumUnitsInRange(x, y, range, filter, counted)
    if counted then
        GroupEnumUnitsInRangeCounted(self.__obj, x, y, range, filter, counted)     
    else
        GroupEnumUnitsInRange(self.__obj, x, y, range, filter)
    end
end    
function UnitGroup:enumUnitsOfType(unitname, filter, counted) 
    if counted then
        GroupEnumUnitsOfTypeCounted(self.__obj, unitname, filter, counted)
    else
        GroupEnumUnitsofType(self.__obj, unitname, filter)
    end
end
-- not wrapped in the Rect class yet.
function UnitGroup:enumUnitsInRect(rect, filter, counted) 
    if counted then
        GroupEnumUnitsInRectCounted(self.__obj, rect, filter, counted)
    else
        GroupEnumUnitsInRect(self.__obj, unitname, filter)
    end
end
function UnitGroup:enumUnitsInRangeOfLoc(loc, filter, counted) 
    self:enumUnitsInRange(GetLocationX(loc), GetLocationY(loc), filter, counted)
end
