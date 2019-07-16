-- Originally made by Quilnez

SCREEN_WIDTH = 1360
SCREEN_HEIGHT = 768

local AUTOMATIC_ADJUSTMENT = true
local RESOLUTION_CHECK_INTERVAL = 0.1
local PERSISTENT_CHILD_PROPERTIES = true

local WidthFactor = 1.0
local HeightFactor = 1.0

local AllComponents = {}
UIUtils = {}

init(function ()
	RefreshResolution()

	FrameGameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
	FrameWorld = BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0)
	FrameHeroBar = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BAR, 0)
	FramePortrait = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT, 0)
	FrameMinimap = BlzGetOriginFrame(ORIGIN_FRAME_MINIMAP, 0)
	FrameTooltip = BlzGetOriginFrame(ORIGIN_FRAME_TOOLTIP, 0)
	FrameUberTooltip = BlzGetOriginFrame(ORIGIN_FRAME_UBERTOOLTIP, 0)
	FrameChatMsg = BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG, 0)
	FrameUnitMsg = BlzGetOriginFrame(ORIGIN_FRAME_UNIT_MSG, 0)
	FrameTopMsg = BlzGetOriginFrame(ORIGIN_FRAME_TOP_MSG, 0)

	for i=0,11 do
		FrameHeroButton[i] = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, i)
		FrameHeroHPBar[i] = BlzGetOriginFrame(ORIGIN_FRAME_HERO_HP_BAR, i)
		FrameHeroMPBar[i] = BlzGetOriginFrame(ORIGIN_FRAME_HERO_MANA_BAR, i)
		FrameHeroIndicator[i] = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, i)
		FrameItemButton[i] = BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, i)
		FrameCommandButton[i] = BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, i)
		FrameSystemButton[i] = BlzGetOriginFrame(ORIGIN_FRAME_SYSTEM_BUTTON, i)
		FrameMinimapButton[i] = BlzGetOriginFrame(ORIGIN_FRAME_MINIMAP_BUTTON, i)
	end

	FrameConsoleUI = BlzGetFrameByName("ConsoleUI", 0)

	if AUTOMATIC_ADJUSTMENT then
		TimerStart(CreateTimer(), RESOLUTION_CHECK_INTERVAL, true, function()
			if BlzGetLocalClientWidth() ~= ResolutionWidth or BlzGetLocalClientHeight() ~= ResolutionHeight then
				RefreshResolution()
			end
		end)
	end
end)

ResolutionWidth = 0
ResolutionHeight = 0
AspectWidth = 0
AspectHeight = 0
IsFullScreen = false
CommandButtonsVisible = true
RefAspectWorld = 5.0 -- local
RefAspectWidth = 4.0 -- local
RefAspectHeight = 3.0 -- local
RefExtraWidth = 0.0 -- local
MinFrameX = 0.0
MaxFrameX = 0.0
DPIMinX = 0.0
DPIMaxX = 0.0
DPIMinY = 0.0
DPIMaxY = RefAspectHeight/RefAspectWorld
PxToDPI = 0.0 -- local
-- FrameGameUI
-- FrameWorld
-- FrameHeroBar
FrameHeroButton = {}
FrameHeroHPBar = {}
FrameHeroMPBar = {}
FrameHeroIndicator = {}
FrameItemButton = {}
FrameCommandButton = {}
FrameSystemButton = {}
-- FramePortrait
-- FrameMinimap
FrameMinimapButton = {}
-- FrameTooltip
-- FrameUberTooltip
-- FrameChatMsg
-- FrameUnitMsg
-- FrameTopMsg
-- FrameConsoleUI

local function CalcAspectRatio(w, h, aw)
	math.floor(aw*h/w+0.5)
end

function XCoordToDPI(x)
	return x*PxToDPI/RefAspectWidth+DPIMinX
end

function YCoordToDPI(y)
	return y*PxToDPI/RefAspectWidth
end

function SizeToDPI(r)
	return r*PxToDPI/RefAspectWidth
end

function DPIToXCoord(dpi)
	return (dpi-DPIMinX)*RefAspectWidth/PxToDPI
end

function DPIToYCoord(dpi)
	return dpi*RefAspectWidth/PxToDPI
end

function DPIToSize(dpi)
	return dpi*RefAspectWidth/PxToDPI
end

function RefreshResolution()
	ResolutionWidth = BlzGetLocalClientWidth()
	ResolutionHeight = BlzGetLocalClientHeight()
	WidthFactor = ResolutionWidth/SCREEN_WIDTH
	HeightFactor = ResolutionHeight/SCREEN_HEIGHT
	if CalcAspectRatio(ResolutionWidth, ResolutionHeight, 4) == 3 then
		PxToDPI = RefAspectWidth/(ResolutionWidth/1024.0*1280.0)
		AspectWidth = 4
		AspectHeight = 3
		RefExtraWidth = 0.0
	elseif CalcAspectRatio(ResolutionWidth, ResolutionHeight, 16) == 9 then
		PxToDPI = RefAspectWidth/(ResolutionWidth/1360.0*1280.0)
		AspectWidth = 16
		AspectHeight = 9
		RefExtraWidth = 0.525
	elseif CalcAspectRatio(ResolutionWidth, ResolutionHeight, 16) == 10 then
		PxToDPI = RefAspectWidth/(ResolutionWidth/1280.0*1280.0)
		AspectWidth = 16
		AspectHeight = 10
		RefExtraWidth = 0.4
	end
	MinFrameX = RefExtraWidth * 320.0
	MaxFrameX = ResolutionWidth-MinFrameX
	DPIMinX = -(RefExtraWidth/RefAspectWidth)
	DPIMaxX = RefAspectWidth/RefAspectWorld-DPIMinX
end

function FullScreenMode(state, commandBtn)
	IsFullScreen = state
	CommandButtonsVisible = commandBtn
	BlzHideOriginFrames(state)
	BlzFrameClearAllPoints(FrameWorld)
	BlzFrameClearAllPoints(FrameConsoleUI)
	if state then -- Fit viewport to screen
		BlzFrameSetAllPoints(FrameWorld, FrameGameUI)
		BlzFrameSetAbsPoint(FrameConsoleUI, FRAMEPOINT_RIGHT, XCoordToDPI(-999.0), YCoordToDPI(-999.0))
		-- Retain in-game message frame position
		yo  = SizeToDPI(300.0)
		xo1 = SizeToDPI(65.0)
		xo2 = SizeToDPI(710.0)
		BlzFrameClearAllPoints(FrameUnitMsg)
		BlzFrameSetAbsPoint(FrameUnitMsg, FRAMEPOINT_TOPLEFT, xo1, 0.5)
		BlzFrameSetAbsPoint(FrameUnitMsg, FRAMEPOINT_TOPRIGHT, xo2, 0.5)
		BlzFrameSetAbsPoint(FrameUnitMsg, FRAMEPOINT_BOTTOMLEFT, xo1, yo)
		BlzFrameSetAbsPoint(FrameUnitMsg, FRAMEPOINT_BOTTOMRIGHT, xo2, yo)
	else -- Restore viewport
		BlzFrameSetAbsPoint(FrameWorld, FRAMEPOINT_TOPLEFT, 0.0, 0.58)
		BlzFrameSetAbsPoint(FrameWorld, FRAMEPOINT_TOPRIGHT, 0.8, 0.58)
		BlzFrameSetAbsPoint(FrameWorld, FRAMEPOINT_BOTTOMLEFT, 0.0, 0.13)
		BlzFrameSetAbsPoint(FrameWorld, FRAMEPOINT_BOTTOMRIGHT, 0.8, 0.13)
		BlzFrameSetAllPoints(FrameConsoleUI, FrameGameUI)
	end

	if commandBtn or not state then
		x = 959.0
		y = 168.0
	end
	for i = 0,11 do
		if FrameCommandButton[i] == nil then
			break
		end
		BlzFrameClearAllPoints(FrameCommandButton[i])
		if commandBtn or not state then -- Restore command buttons position
			BlzFrameSetAbsPoint(FrameCommandButton[i], FRAMEPOINT_TOPLEFT, XCoordToDPI(x), YCoordToDPI(y))
			if i == 3 or i == 7 then
				x = 959.0
				y = y - DPIToSize(BlzFrameGetHeight(FrameCommandButton[i])) - 6.0
			else
				x = x + DPIToSize(BlzFrameGetWidth (FrameCommandButton[i])) + 7.0
			end
		else -- Get command buttons out of screen
			BlzFrameSetAbsPoint(FrameCommandButton[i], FRAMEPOINT_RIGHT, XCoordToDPI(-999.0), YCoordToDPI(-999.0))
		end
	end
end

function CalcFrameSpacing(from, to, topdown)
	anchor1 = from.anchorPoint
	anchor2 = to.anchorPoint

	if topdown then
		size1 = from.height
		size2 = to.height
		if anchor1 == FRAMEPOINT_TOPLEFT or anchor1 == FRAMEPOINT_TOP or anchor1 == FRAMEPOINT_TOPRIGHT then
			size1 = 0.0
		elseif anchor1 == FRAMEPOINT_LEFT or anchor1 == FRAMEPOINT_CENTER or anchor1 == FRAMEPOINT_RIGHT then
			size1 = size1*0.5
		end
		if anchor2 == FRAMEPOINT_BOTTOMLEFT or anchor2 == FRAMEPOINT_BOTTOM or anchor2 == FRAMEPOINT_BOTTOMRIGHT then
			size2 = 0.0
		elseif anchor2 == FRAMEPOINT_LEFT or anchor2 == FRAMEPOINT_CENTER or anchor2 == FRAMEPOINT_RIGHT then
			size2 = size2*0.5
		end
	else
		size1 = from.width
		size2 = to.width
		if anchor1 == FRAMEPOINT_TOPRIGHT or anchor1 == FRAMEPOINT_RIGHT or anchor1 == FRAMEPOINT_BOTTOMRIGHT then
			size1 = 0.0
		elseif anchor1 == FRAMEPOINT_TOP or anchor1 == FRAMEPOINT_CENTER or anchor1 == FRAMEPOINT_BOTTOM then
			size1 = size1*0.5
		end
		if anchor2 == FRAMEPOINT_TOPLEFT or anchor2 == FRAMEPOINT_LEFT or anchor2 == FRAMEPOINT_BOTTOMLEFT then
			size2 = 0.0
		elseif anchor2 == FRAMEPOINT_TOP or anchor2 == FRAMEPOINT_CENTER or anchor2 == FRAMEPOINT_BOTTOM then
			size2 = size2*0.5
		end
	end
	return size1+size2
end

---@class UIComponent
UIComponent = {}
UIComponent.__index = UIComponent

UIComponent.Null = 0 -- readonly
UIComponent.EnumChild = 0 -- readonly
UIComponent.TriggerComponent = 0 -- readonly

UIComponent.TYPE_TEXT = "UIUtilsText" -- readonly
UIComponent.TYPE_SIMPLE_TEXT = "UIUtilsSimpleText" -- readonly
UIComponent.TYPE_TEXTURE = "UIUtilsTexture" -- readonly
UIComponent.TYPE_SIMPLE_TEXTURE = "UIUtilsSimpleTexture" -- readonly
UIComponent.TYPE_BUTTON = "UIUtilsButton" -- readonly
UIComponent.TYPE_BAR = "UIUtilsBar" -- readonly
UIComponent.TYPE_H_SLIDER = "UIUtilsSliderH" -- readonly
UIComponent.TYPE_V_SLIDER = "UIUtilsSliderV" -- readonly

UIComponent.ExecTrigg = CreateTrigger() -- private
UIComponent.GC = InitGameCache("UIUtils.w3v") -- private
UIComponent.HT = InitHashtable() -- private

function IsSimple(frameType, isSimple)
	return 	frameType == UIComponent.TYPE_SIMPLE_TEXT or
			frameType == UIComponent.TYPE_SIMPLE_TEXTURE or
			frameType == UIComponent.TYPE_BAR or
			isSimple and
			not (frameType == UIComponent.TYPE_TEXT or
				frameType == UIComponent.TYPE_TEXTURE or
				frameType == UIComponent.TYPE_BUTTON or
				frameType == UIComponent.TYPE_H_SLIDER or
				frameType == UIComponent.TYPE_V_SLIDER)
end

function GetTriggerComponent()
	UIComponent.TriggerComponent = LoadInteger(UIComponent.HT, GetHandleId(BlzGetTriggerFrame()), 0)
end

---@param func function
function UIComponent:onAnyEvent(func)
    if self.anyEventTrigg == nil then
		self.anyEventTrigg = CreateTrigger()
		for i = 1,16 do
            BlzTriggerRegisterFrameEvent(self.anyEventTrigg, self.frame, ConvertFrameEventType(i))
        end
        TriggerAddCondition(self.anyEventTrigg, Condition(GetTriggerComponent))
    end
    return TriggerAddCondition(self.anyEventTrigg, Condition(func))
end


---@param x number
---@param y number
function UIComponent:move(x, y)
    self.localX = x
    self.localY = y
	if self.parent == UIComponent.Null then
        self.screenX = x
        self.screenY = y
    else
        self.screenX = self.parent.screenX + self.localX * self.parent:getScale()
        self.screenY = self.parent.screenY + self.localY * self.parent:getScale()
    end
	BlzFrameSetAbsPoint(self.frame, self.anchor,
		XCoordToDPI(self.screenX*WidthFactor),
		YCoordToDPI(self.screenY*HeightFactor))

	for node in self.child do
		node:move(node.localX, node.localY)
	end
end

---@param x number
---@param y number
function UIComponent:moveEx(x, y)
	if self.parent == UIComponent.Null then
		self:move(x,y)
	else
		self:move((x-self.parent.screenX) / self.parent.localSize, (y-self.parent.screenY) / self.parent.localSize)
	end
end

---@param relative UIComponent
---@param x number
---@param y number
function UIComponent:relate(relative, x, y)
	if self.parent == UIComponent.Null then
        self:move(relative.screenX+x, relative.screenY+y)
	else
        self:moveEx(relative.screenX+x, relative.screenY+y)
	end
end

---@param point framepointtype
function UIComponent:anchorPoint(point)
    self.anchor = point
	BlzFrameClearAllPoints(self.frame)
    self:move(self.localX, self.localY)
end

---@param comp UIComponent
function UIComponent:setParent(comp)
    if comp ~= UIComponent.Null then
        if self.parent ~= comp then
            self.removeNode()
        end
        comp.child.insertNode(self)
    end

    if not PERSISTENT_CHILD_PROPERTIES then
        if self.parent ~= UIComponent.Null then
            self.setLocalScale(self.localSize * self.parent.localSize)
        end
        self.localX = self.screenX - comp.screenX
        self.localY = self.screenY - comp.screenY
    end

    self.parent = comp
    self.parent.setLocalScale(self.parent.localSize)
end

---@param str string
function UIComponent:setText(str)
    BlzFrameSetText(self.textFrameH, str)
end

---@param len integer
function UIComponent:setMaxLength(len)
    BlzFrameSetTextSizeLimit(self.textFrameH, len)
end

---@param color integer
function UIComponent:setTextColor(color)
    BlzFrameSetTextColor(self.textFrameH, color)
end

---@param filePath string
function UIComponent:setTexture(filePath)
	self.mainTextureFile = filePath
    BlzFrameSetTexture(self.mainTextureH, filePath, 0, true)
    if self.disabledTextureFile:len() == 0 then
        self.disabledTexture = filePath
    end
    if self.pushedTextureFile:len() == 0 then
        self.pushedTexture = filePath
    end
end

---@param filePath string
function UIComponent:setDisabledTexture(filePath)
    self.disabledTextureFile = filePath
    BlzFrameSetTexture(self.disabledTextureH, filePath, 0, true)
end

---@param filePath string
function UIComponent:setHighlightTexture(filePath)
    self.highlightTextureFile = filePath
    BlzFrameSetTexture(self.highlightTextureH, filePath, 0, true)
end

---@param filePath string
function UIComponent:setPushedTexture(filePath)
    self.pushedTextureFile = filePath
    BlzFrameSetTexture(self.pushedTextureH, filePath, 0, true)
end

---@param filePath string
function UIComponent:setBackgroundTexture(filePath)
    self.backgroundTextureFile = filePath
    BlzFrameSetTexture(self.backgroundTextureH, filePath, 0, true)
end

---@param filePath string
function UIComponent:setBorderTexture(filePath)
    self.borderTextureFile = filePath
    BlzFrameSetTexture(self.borderTextureH, filePath, 0, true)
end

---@param filePath string
function UIComponent:setModel(filePath)
    self.modelFile = filePath
    BlzFrameSetModel(self.modelFrameH, filePath, 0)
end

---@param color integer
function UIComponent:setVertexColor(color)
    BlzFrameSetVertexColor(self.modelFrameH, color)
end

---@param r number
function UIComponent:setValue(r)
    BlzFrameSetValue(self.frame, r)
end

function UIComponent:getValue(r)
    return BlzFrameGetValue(self.frame)
end

---@param r number
function UIComponent:setStepSize(r)
	if r < 0.0001 then
		r = 0.0001
	end
	self.step = r
    BlzFrameSetStepSize(self.frame, self.step)
end

---@param r number
function UIComponent:setLocalScale(r)
	if r < 0.0001 then
		r = 0.0001
	end
	self.localSize = r
	self:ize(self.width, self.height)
	self:move(self.localX, self.localY)
	
	for node in self.child do
		node:setLocalScale(node.localSize)
	end
end

function UIComponent:getScale()
	if self.parent == UIComponent.Null then
		return self.localSize
	else
		return self.localSize * self.parent:getScale()
	end
end

---@param level integer
function UIComponent:setLevel(level)
    self.lvl = level
    BlzFrameSetLevel(self.frame, level)
end

---@param amount integer
function UIComponent:setVALUE(amount)
    BlzFrameSetAlpha(self.frame, amount)
end
function UIComponent:getVALUE()
    return BlzFrameGetAlpha(self.frame)
end

---@param state boolean
function UIComponent:setVisible(state)
    BlzFrameSetVisible(self.frame, state)
end
function UIComponent:getVisible()
    return BlzFrameIsVisible(self.frame)
end

---@param state boolean
function UIComponent:setEnabled(state)
    BlzFrameSetEnable(self.frame, state)
end
function UIComponent:getEnabled()
    return BlzFrameGetEnable(self.frame)
end

---@param width number
---@param height number
function UIComponent:ize(width, height)
	if width < 0 then
		width = 0
	end
	if height < 0 then
		height = 0
	end
	BlzFrameSetSize(frame,
		SizeToDPI(self.localWidth*self.scale*WidthFactor),
		SizeToDPI(self.localHeight*self.scale*WidthFactor))
end

---@param DATA TYPE
function UIComponent:setVALUE(DATA)
end

---@param DATA TYPE
function UIComponent:setVALUE(DATA)
end

---@param DATA TYPE
function UIComponent:setVALUE(DATA)
end

function UIComponent:new(isSimple, frameType, parent, x, y, level)
	o = setmetatable(o, self)

    o.context = GetStoredInteger(self.GC, frameType, "0") -- readonly
	tempInt = GetStoredInteger(self.GC, frameType, o.context) -- readonly
    if tempInt == 0 then
        StoreInteger(self.GC, frameType, "0", o.context+1)
    else
        StoreInteger(self.GC, frameType, "0", tempInt)
	end
	
	if IsSimple(frameType, isSimple) then
		o.frame = BlzCreateSimpleFrame(frameType, UIUtils.FrameGameUI, o.context)
    else
		o.frame = BlzCreateFrame(frameType, UIUtils.FrameGameUI, 0, o.context)
	end -- readonly
	o.textFrameH = getSubFrame(frameType + "Text") -- private
	o.modelFrameH = getSubFrame(frameType + "Model") -- private
	o.mainTextureH = getSubFrame(frameType + "Texture") -- private
	o.disabledTextureH = getSubFrame(frameType + "Disabled") -- private
	o.pushedTextureH = getSubFrame(frameType + "Pushed") -- private
	o.highlightTextureH = getSubFrame(frameType + "Highlight") -- private
	o.backgroundTextureH = getSubFrame(frameType + "Background") -- private
	o.borderTextureH = getSubFrame(frameType + "Border") -- private
    if o.mainTextureH == nil then
       o.mainTextureH = frame
	end
   
	o:setLocalScale(1.0)
    o.localWidth = DPIToSize(BlzFrameGetWidth(o.frame)) -- private
	o.localHeight = DPIToSize(BlzFrameGetHeight(o.frame)) -- private
	
    o.anchor = FRAMEPOINT_BOTTOMLEFT -- private
    -- o.child = createNode() -- private
    o.frameType = frameType -- readonly
	o.name = frameType .. o.context
	o:setParent(parent)
    o.level = level --! public operator
    o.value = 0.0 --! public operator

	o.mainTextureFile        = "" -- private
	o.disabledTextureFile    = "" -- private
	o.pushedTextureFile        = "" -- private
	o.highlightTextureFile    = "" -- private
	o.backgroundTextureFile    = "" -- private
	o.borderTextureFile        = "" -- private
	o.modelFile                = "" -- private

    -- o.localX -- readonly
    -- o.localY -- readonly
    -- o.screenX -- readonly
    -- o.screenY -- readonly
    -- o.minValue -- readonly
    -- o.maxValue -- readonly

    -- o.parent -- private
    -- o.tips -- private
    -- o.lvl -- private
    -- o.step -- private
    -- o.anyEventTrigg -- private
	return o
end