require('CeresStdLib.handle.handle')

rect                = Handle:new()
rect.__props.maxX       = {
    get                 = function(t) return GetRectMaxX(t.__obj) end,
    set                 = function(t, v) SetRect(t.__obj, GetRectMinX(t.__obj), GetRectMinY(t.__obj), v, GetRectMaxY(t.__obj)) end
}
rect.__props.maxY       = {
    get                 = function(t) return GetRectMaxY(t.__obj) end,
    set                 = function(t, v) SetRect(t.__obj, GetRectMinX(t.__obj), GetRectMinY(t.__obj), GetRectMaxX(t.__obj), v) end
}
rect.__props.minX       = {
    get                 = function(t) return GetRectMinX(t.__obj) end,
    set                 = function(t, v) SetRect(t.__obj, v, GetRectMinY(t.__obj), GetRectMaxX(t.__obj), GetRectMaxY(t.__obj)) end
}
rect.__props.minY       = {
    get                 = function(t) return GetRectMinY(t.__obj) end,
    set                 = function(t, v) SetRect(t.__obj, GetRectMinX(t.__obj), v, GetRectMaxX(t.__obj), GetRectMaxY(t.__obj)) end
}
rect.__props.centerX    = {
    get                 = function(t) return GetRectCenterX(t.__obj) end,
    set                 = function(t, v) MoveRectTo(t.__obj, v, GetRectCenterY(t.__obj)) end
}
rect.__props.centerY    = {
    get                 = function(t) return GetRectCenterY(t.__obj) end,
    set                 = function(t, v) MoveRectTo(t.__obj, GetRectCenterX(t.__obj), v) end
}

function rect.new(minx, miny, maxx, maxy) return rect.wrap(Rect(minx, miny, maxx, maxy)) end
function rect:set(minx, miny, maxx, maxy) SetRect(self.__obj, minx, miny, maxx, maxy) end
function rect:move(centerX, centerY) MoveRectTo(self.__obj, centerX, centerY) end
function rect:setLoc(loc1, loc2) SetRectFromLoc(self.__obj, loc1, loc2) end
function rect:moveLoc(loc) self:move(GetLocationX(loc), GetLocationY(loc)) end
function rect:destroy() RemoveRect(self.__obj) self:unwrap() end

function rect.worldBounds() return rect.wrap(GetWorldBounds()) end
function rect.playableArea() return rect.wrap(bj_mapInitialPlayableArea) end