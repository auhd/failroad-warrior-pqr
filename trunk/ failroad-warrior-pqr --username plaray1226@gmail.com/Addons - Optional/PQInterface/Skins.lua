----[[ Ini ]]------------------------------------------------------------------------------------------------------------------
local AddOnName, Env = ... local ADDON = Env[1] 
local D = ADDON.development
----[[ Ace Ini ]]--------------------------------------------------------------------------------------------------------------

----[[ Lua Ini ]]--------------------------------------------------------------------------------------------------------------
local select, unpack						= select, unpack
local type	 								= type
local sub, find, format 				= string.sub, string.find, string.format
local floor, ceil, min, max			= math.floor, math.ceil, math.min, math.max
----[[ WoW Ini ]]--------------------------------------------------------------------------------------------------------------
local GetSpellInfo, GetTime  = GetSpellInfo, GetTime


----[[ Locals ]]---------------------------------------------------------------------------------------------------------------
local function CreateOutline(frame,padding,color,GradientTopAlpha,GradientBottomAlpha,layer,sublayer,anchor)
		anchor = anchor or frame
		layer = layer or 'BACKGROUND'
		color = color or {1,1,1}
		sublayer = sublayer or 3
		padding = padding or 0		
		local outlineTop = frame:CreateTexture(nil,layer,nil,sublayer)
		outlineTop:SetPoint("TOPLEFT",anchor,"TOPLEFT", padding+1,-padding) outlineTop:SetPoint("TOPRIGHT",anchor,"TOPRIGHT", -padding-1,-padding)
		outlineTop:SetHeight(1)
		outlineTop:SetTexture(color[1],color[1],color[1],GradientTopAlpha or 1)
		local outlineBottom = frame:CreateTexture(nil,layer,nil,sublayer)
		outlineBottom:SetPoint("BOTTOMLEFT",anchor,"BOTTOMLEFT",padding+1,padding) outlineBottom:SetPoint("BOTTOMRIGHT",anchor,"BOTTOMRIGHT", -padding-1,padding)
		outlineBottom:SetHeight(1)
		outlineBottom:SetTexture(color[1],color[1],color[1],GradientBottomAlpha or 1)
		local outlineLeft = frame:CreateTexture(nil,layer,nil,sublayer)
		outlineLeft:SetPoint("TOPLEFT",padding,-padding) outlineLeft:SetPoint("BOTTOMLEFT", padding,padding)
		outlineLeft:SetWidth(1)
		outlineLeft:SetTexture(color[1],color[1],color[1])
		
		if GradientTopAlpha then outlineLeft:SetGradientAlpha("VERTICAL",1,1,1,GradientBottomAlpha,1,1,1,GradientTopAlpha) end
		local outlineRight = frame:CreateTexture(nil,layer,nil,sublayer)
		outlineRight:SetPoint("TOPRIGHT",anchor,"TOPRIGHT", -padding,-padding) outlineRight:SetPoint("BOTTOMRIGHT",anchor,"BOTTOMRIGHT",-padding,padding)
		outlineRight:SetWidth(1)
		outlineRight:SetTexture(color[1],color[1],color[1])
		if GradientTopAlpha then outlineRight:SetGradientAlpha("VERTICAL",1,1,1,GradientBottomAlpha,1,1,1,GradientTopAlpha) end
	
end
local function CreateHighlights(frame,topGradientTop,topGradientBottom,bottomGradientTop,bottomGradientBottom,topHeight,bottomHeight,layer,sublayer,center)
		topHeight = topHeight or 10
		bottomHeight = bottomHeight or 6
		layer = layer or 'BACKGROUND'
		sublayer = sublayer or 2
		local topHighlight = frame:CreateTexture(nil,layer,sublayer)
		topHighlight:SetPoint("TOPLEFT") topHighlight:SetPoint("TOPRIGHT")		
		topHighlight:SetHeight(topHeight)
		topHighlight:SetTexture(1,1,1,1)
		topHighlight:SetGradientAlpha("VERTICAL",1,1,1,topGradientBottom,1,1,1,topGradientTop)
		
		local botomHighlight = frame:CreateTexture(nil,layer,sublayer)
		botomHighlight:SetPoint("BOTTOMLEFT") botomHighlight:SetPoint("BOTTOMRIGHT")		
		botomHighlight:SetHeight(bottomHeight)
		botomHighlight:SetTexture(1,1,1,1)
		botomHighlight:SetGradientAlpha("VERTICAL",1,1,1,bottomGradientBottom,1,1,1,bottomGradientTop)
end
local function CreateGlassFrame(frame,glassAlpha,glassOutlineAlpha,shadowAlpha,shadowOutlineAlpha)
	local shadow = CreateFrame("Frame",nil,frame)
	shadow:SetPoint("TOPLEFT", -18, 18)
	shadow:SetPoint("BOTTOMRIGHT", 18, -18)
	shadow:SetBackdrop({ edgeFile = ADDON.mediaPath.."PQRShadow",edgeSize = 28 })
	shadow:SetBackdropBorderColor(0,0,0,shadowAlpha)

	local background = frame:CreateTexture(nil,'BACKGROUND',nil,-8)
	background:SetPoint("TOPLEFT", 2,-2)
	background:SetPoint("BOTTOMRIGHT", -2, 2)
	background:SetTexture(0,0,0)

	local shadowOutlineTOP = frame:CreateTexture(nil,'BACKGROUND')
	shadowOutlineTOP:SetPoint("TOPLEFT", 1, 1) shadowOutlineTOP:SetPoint("TOPRIGHT", -1, 1)
	shadowOutlineTOP:SetHeight(1)
	shadowOutlineTOP:SetTexture(0,0,0,shadowOutlineAlpha)
	local shadowOutlineBottom = frame:CreateTexture(nil,'BACKGROUND')
	shadowOutlineBottom:SetPoint("BOTTOMLEFT", 1, -1) shadowOutlineBottom:SetPoint("BOTTOMRIGHT", -1, -1)
	shadowOutlineBottom:SetHeight(1)
	shadowOutlineBottom:SetTexture(0,0,0,shadowOutlineAlpha)
	local shadowOutlineLeft = frame:CreateTexture(nil,'BACKGROUND')
	shadowOutlineLeft:SetPoint("TOPLEFT", -1, -1) shadowOutlineLeft:SetPoint("BOTTOMLEFT", -1, 1)
	shadowOutlineLeft:SetWidth(1)
	shadowOutlineLeft:SetTexture(0,0,0,shadowOutlineAlpha)
	local shadowOutlineRight = frame:CreateTexture(nil,'BACKGROUND')
	shadowOutlineRight:SetPoint("TOPRIGHT", 1,-1) shadowOutlineRight:SetPoint("BOTTOMRIGHT", 1, 1)
	shadowOutlineRight:SetWidth(1)
	shadowOutlineRight:SetTexture(0,0,0,shadowOutlineAlpha)

	local shadowOutlineTL = frame:CreateTexture(nil,'BACKGROUND')
	shadowOutlineTL:SetPoint("TOPLEFT")
	shadowOutlineTL:SetSize(1,1)
	shadowOutlineTL:SetTexture(0,0,0,shadowOutlineAlpha)
	local shadowOutlineBL = frame:CreateTexture(nil,'BACKGROUND')
	shadowOutlineBL:SetPoint("BOTTOMLEFT")
	shadowOutlineBL:SetSize(1,1)
	shadowOutlineBL:SetTexture(0,0,0,shadowOutlineAlpha)
	local shadowOutlineTR = frame:CreateTexture(nil,'BACKGROUND')
	shadowOutlineTR:SetPoint("TOPRIGHT")
	shadowOutlineTR:SetSize(1,1)
	shadowOutlineTR:SetTexture(0,0,0,shadowOutlineAlpha)
	local shadowOutlineBR = frame:CreateTexture(nil,'BACKGROUND')
	shadowOutlineBR:SetPoint("BOTTOMRIGHT")
	shadowOutlineBR:SetSize(1,1)
	shadowOutlineBR:SetTexture(0,0,0,shadowOutlineAlpha)

	local glassTOP = frame:CreateTexture(nil,'BACKGROUND')
	glassTOP:SetPoint("TOPLEFT", 1, -1) glassTOP:SetPoint("TOPRIGHT", -1, -1)
	glassTOP:SetHeight(2)
	glassTOP:SetTexture(1,1,1,glassAlpha)
	local glassBottom = frame:CreateTexture(nil,'BACKGROUND')
	glassBottom:SetPoint("BOTTOMLEFT", 1, 1) glassBottom:SetPoint("BOTTOMRIGHT", -1, 1)
	glassBottom:SetHeight(2)
	glassBottom:SetTexture(1,1,1,glassAlpha)
	local glassLeft = frame:CreateTexture(nil,'BACKGROUND')
	glassLeft:SetPoint("TOPLEFT", 1, -3) glassLeft:SetPoint("BOTTOMLEFT", 1, 3)
	glassLeft:SetWidth(2)
	glassLeft:SetTexture(1,1,1,glassAlpha)
	local glassRight = frame:CreateTexture(nil,'BACKGROUND')
	glassRight:SetPoint("TOPRIGHT", -1, -3) glassRight:SetPoint("BOTTOMRIGHT", -1, 3)
	glassRight:SetWidth(2)
	glassRight:SetTexture(1,1,1,glassAlpha)
	local glassHLTOP = frame:CreateTexture(nil,'BACKGROUND')
	glassHLTOP:SetPoint("TOPLEFT", 1, 0) glassHLTOP:SetPoint("TOPRIGHT", -1, 0)
	glassHLTOP:SetHeight(1)
	glassHLTOP:SetTexture(1,1,1,glassOutlineAlpha)
	local glassHLBottom = frame:CreateTexture(nil,'BACKGROUND')
	glassHLBottom:SetPoint("BOTTOMLEFT", 1, 0) glassHLBottom:SetPoint("BOTTOMRIGHT", -1, 0)
	glassHLBottom:SetHeight(1)
	glassHLBottom:SetTexture(1,1,1,glassOutlineAlpha)
	local glassHLLeft = frame:CreateTexture(nil,'BACKGROUND')
	glassHLLeft:SetPoint("TOPLEFT", 0, -1) glassHLLeft:SetPoint("BOTTOMLEFT", 0, 1)
	glassHLLeft:SetWidth(1)
	glassHLLeft:SetTexture(1,1,1,glassOutlineAlpha)
	local glassHLRight = frame:CreateTexture(nil,'BACKGROUND')
	glassHLRight:SetPoint("TOPRIGHT", 0, -1) glassHLRight:SetPoint("BOTTOMRIGHT", 0, 1)
	glassHLRight:SetWidth(1)
	glassHLRight:SetTexture(1,1,1,glassOutlineAlpha)

end
local function CreateDivider(frame,top,bottom,pos,anchor,layer,sublayer)
	pos = pos or 0
	anchor = anchor or frame
	layer = layer or "ARTWORK"
	sublayer = sublayer or 1
	local outlineLeft = frame:CreateTexture(nil,layer,sublayer)
	outlineLeft:SetPoint("TOP",0,-1) outlineLeft:SetPoint("BOTTOM",0,1)
	outlineLeft:SetPoint("RIGHT",anchor,"RIGHT",pos,0)
	outlineLeft:SetWidth(1)
	outlineLeft:SetTexture(1,1,1)
	outlineLeft:SetGradientAlpha("VERTICAL",1,1,1,bottom,1,1,1,top)
	local outlineMid = frame:CreateTexture(nil,layer,sublayer)
	outlineMid:SetPoint("TOP") outlineMid:SetPoint("BOTTOM")
	outlineMid:SetPoint("RIGHT",anchor,"RIGHT",pos+1,0)
	outlineMid:SetWidth(1)
	outlineMid:SetTexture(0,0,0)
	local outlineRight = frame:CreateTexture(nil,layer,sublayer)
	outlineRight:SetPoint("TOP",0,-1) outlineRight:SetPoint("BOTTOM",0,1)
	outlineRight:SetPoint("RIGHT",anchor,"RIGHT",pos+2,0)
	outlineRight:SetWidth(1)
	outlineRight:SetTexture(1,1,1)
	outlineRight:SetGradientAlpha("VERTICAL",1,1,1,bottom,1,1,1,top)	
end
----[[ Skins ]]----------------------------------------------------------------------------------------------------------------	
--[[----------------------
 -8	background	
  0	higlights	
--]]----------------------
function ADDON:SkinInterface(interface)

	--[ Interface ]--
	local glassAlpha 				= .05
	local glassOutlineAlpha 	= .2
	local shadowAlpha 			= .6
	local shadowOutlineAlpha 	= .1
	CreateGlassFrame(interface,glassAlpha,glassOutlineAlpha,shadowAlpha,shadowOutlineAlpha)
	--[ StatusBar ]--
	local outlineGradientTop					= .2
	local outlineGradientBottom				= .07
	local topHighlightGradientTop				= .3
	local topHighlightGradientBottom			= .13
	local bottomHighlightGradientTop			= 0
	local bottomHighlightGradientBottom		= .1
	CreateOutline(interface.statusBar,nil,nil,outlineGradientTop,outlineGradientBottom,'BORDER')
	CreateHighlights(interface.statusBar,topHighlightGradientTop,topHighlightGradientBottom,bottomHighlightGradientTop,bottomHighlightGradientBottom,9,6,'BORDER')
	--[ statusIcon ]--
	CreateOutline(interface.statusIcon,nil,nil,.1,.1,'BORDER')
	CreateHighlights(interface.statusIcon,.12,.07,0,0,9,6,'BORDER')

	local cornerHLVert = interface.statusIcon:CreateTexture(nil)
	cornerHLVert:SetPoint("TOPLEFT")
	cornerHLVert:SetSize(1,10)
	cornerHLVert:SetTexture(1,1,1)
	cornerHLVert:SetGradientAlpha("VERTICAL",1,1,1,0,1,1,1,.3)
	local cornerHLHorz = interface.statusIcon:CreateTexture(nil)
	cornerHLHorz:SetPoint("TOPLEFT")
	cornerHLHorz:SetSize(10,1)
	cornerHLHorz:SetTexture(1,1,1)
	cornerHLHorz:SetGradientAlpha("HORIZONTAL",1,1,1,.3,1,1,1,0)

	local black = interface.statusIcon:CreateTexture(nil)
	black:SetPoint("TOPRIGHT",1,0) black:SetPoint("BOTTOMRIGHT", 1,0)
	black:SetWidth(1)
	black:SetTexture(0,0,0)
	local white = interface.statusIcon:CreateTexture(nil)
	white:SetPoint("TOPRIGHT",2,0) white:SetPoint("BOTTOMRIGHT",2,0)
	white:SetWidth(1)
	white:SetTexture(1,1,1)
	white:SetGradientAlpha("VERTICAL",1,1,1,outlineGradientBottom,1,1,1,outlineGradientTop)
	--[ interruptLight ]--
	local dividerPos = -1
	local outlineLeft = interface.interruptLight:CreateTexture(nil,layer,sublayer)
	outlineLeft:SetPoint("TOPLEFT",dividerPos,-1) outlineLeft:SetPoint("BOTTOMLEFT", dividerPos,1)
	outlineLeft:SetWidth(1)
	outlineLeft:SetTexture(1,1,1)
	outlineLeft:SetGradientAlpha("VERTICAL",1,1,1,outlineGradientBottom,1,1,1,outlineGradientTop)
	local outlineMid = interface.interruptLight:CreateTexture(nil,layer,sublayer)
	outlineMid:SetPoint("TOPLEFT",dividerPos-1,-0) outlineMid:SetPoint("BOTTOMLEFT", dividerPos-1,0)
	outlineMid:SetWidth(1)
	outlineMid:SetTexture(0,0,0)
	local outlineRight = interface.interruptLight:CreateTexture(nil,layer,sublayer)
	outlineRight:SetPoint("TOPLEFT",dividerPos-2,-0) outlineRight:SetPoint("BOTTOMLEFT",dividerPos-2,0)
	outlineRight:SetWidth(1)
	outlineRight:SetTexture(1,1,1)
	outlineRight:SetGradientAlpha("VERTICAL",1,1,1,outlineGradientBottom,1,1,1,outlineGradientTop)
	
	--custom Text--
	CreateOutline(interface.customText,nil,nil,.1,.1,'BACKGROUND')
	local background = interface.customText:CreateTexture(nil,'BACKGROUND',nil,-8)
	background:SetAllPoints()	
	background:SetTexture(ADDON.mediaPath.."Background",true)
	background:SetHorizTile(true)
	background:SetVertTile(true)
	
	local shading = interface.customText:CreateTexture(nil,'BACKGROUND',nil,-7)
	shading:SetAllPoints()	
	shading:SetTexture(0,0,0,.4)	
	
end
function ADDON:SkinAblityLog(abilityLog)
	-- AblityLog
	local glassAlpha 				= .05
	local glassOutlineAlpha 	= .2
	local shadowAlpha 			= .6
	local shadowOutlineAlpha 	= .1			
	CreateGlassFrame(abilityLog,glassAlpha,glassOutlineAlpha,shadowAlpha,shadowOutlineAlpha)
	
	--[ Header ]--	
	local outlineGradientTop					= .2
	local outlineGradientBottom				= .07
	local topHighlightGradientTop				= .3
	local topHighlightGradientBottom			= .13
	local bottomHighlightGradientTop			= 0
	local bottomHighlightGradientBottom		= .1	
	CreateOutline(abilityLog.header,nil,nil,outlineGradientTop,outlineGradientBottom,'BACKGROUND',0)
	CreateHighlights(abilityLog.header,topHighlightGradientTop,topHighlightGradientBottom,bottomHighlightGradientTop,bottomHighlightGradientBottom,9,6,'BACKGROUND',0)
	
	CreateDivider(abilityLog.header,outlineGradientTop,outlineGradientBottom,0,abilityLog.header.icon)
	CreateDivider(abilityLog.header,outlineGradientTop,outlineGradientBottom,1,abilityLog.header.field1)
	CreateDivider(abilityLog.header,outlineGradientTop,outlineGradientBottom,1,abilityLog.header.field2)
	CreateDivider(abilityLog.header,outlineGradientTop,outlineGradientBottom,1,abilityLog.header.field3)
	--CreateDivider(abilityLog.header,outlineGradientTop,outlineGradientBottom,1,abilityLog.header.field4)
	
	--[ Header Icon ]--
	CreateOutline(abilityLog.header,0,nil,.25,.25,nil,3,abilityLog.header.icon)
	
	--[ content Background ]--
	local background = abilityLog:CreateTexture(nil)
	background:SetPoint("TOPLEFT",abilityLog.header,"BOTTOMLEFT",0,0)
	background:SetPoint("BOTTOMRIGHT",-3,3)	
	background:SetTexture(ADDON.mediaPath.."Background",true)
	background:SetHorizTile(true)
	background:SetVertTile(true)
	
	CreateOutline(abilityLog.content,1,nil,.12,.12,'BORDER')
	
		
	
		
end
function ADDON:SkinRow(row)
	local outlineGradientTop					= .07
	local outlineGradientBottom				= .07
	
	CreateOutline(row,-1,{0,0,0},1,1)
	CreateOutline(row,0,nil,outlineGradientTop,outlineGradientBottom,'ARTWORK')
	
	local background = row:CreateTexture(nil,'BACKGROUND')
	background:SetAllPoints()	
	background:SetTexture(0,0,0,.4)	
	
	local cornerHLVert = row:CreateTexture(nil,'ARTWORK')
	cornerHLVert:SetPoint("TOPLEFT")
	cornerHLVert:SetSize(1,19)
	cornerHLVert:SetTexture(1,1,1)
	cornerHLVert:SetGradientAlpha("VERTICAL",1,1,1,0,1,1,1,.2)
	local cornerHLHorz = row:CreateTexture(nil,'ARTWORK')
	cornerHLHorz:SetPoint("TOPLEFT")
	cornerHLHorz:SetSize(10,1)
	cornerHLHorz:SetTexture(1,1,1)
	cornerHLHorz:SetGradientAlpha("HORIZONTAL",1,1,1,.2,1,1,1,0)
	
	CreateDivider(row,outlineGradientTop,outlineGradientBottom,0,row.icon)
	CreateDivider(row,outlineGradientTop,outlineGradientBottom,1,row.field1)
	CreateDivider(row,outlineGradientTop,outlineGradientBottom,1,row.field2)
	CreateDivider(row,outlineGradientTop,outlineGradientBottom,1,row.field3)	
end