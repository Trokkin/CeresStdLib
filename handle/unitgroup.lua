require('CeresStdLib.handle.handle')
require('CeresStdLib.handle.unit')
require('CeresStdLib.handle.rect')

UnitGroup               = Handle.new()
UnitGroup.__props.count = {
                    get = function (t) return BlzGroupGetSize(t.__obj) end
                    }

function UnitGroup.create() return UnitGroup.wrap(CreateGroup()) end
function UnitGroup:destroy() DestroyGroup(self.__obj) self:unwrap() end

function UnitGroup.getEnumUnit() return --[[Unit.wrap(GetEnumUnit()) or]] UnitGroup.__enumUnit end
function UnitGroup:unit(index) return Unit.wrap(BlzGroupUnitAt(self.__obj, index)) end
function UnitGroup:first() return Unit.wrap(FirstOfGroup(self.__obj)) end
function UnitGroup:last() return self:unit(self.count - 1) end

function UnitGroup:add(u) return GroupAddUnit(self.__obj, u.__obj) end
function UnitGroup:remove(u) return GroupRemoveUnit(self.__obj, u.__obj) end
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
function UnitGroup:enumUnitsInRect(rects, filter, counted) 
    if counted then
        GroupEnumUnitsInRectCounted(self.__obj, rects.__obj, filter, counted)
    else
        GroupEnumUnitsInRect(self.__obj, rects.__obj, filter)
    end
end
function UnitGroup:enumUnitsInRangeOfLoc(loc, filter, counted) 
    self:enumUnitsInRange(GetLocationX(loc), GetLocationY(loc), filter, counted)
end
function UnitGroup:forEach(callback, destroy)
    if not destroy then
        local j                 = self.count
        for i = 0,j do
            UnitGroup.__enumUnit    = self:unit(i)
            if UnitGroup.__enumUnit ~= nil then
                callback()
            end
        end
    else
        local i                     = 0
        while self.count > i do
            UnitGroup.__enumUnit    = self:unit(i)
            if UnitGroup.__enumUnit ~= nil then
                callback()
                self:remove(UnitGroup.__enumUnit)
            else
                i = i + 1
            end
        end
        self:clear()
    end
end