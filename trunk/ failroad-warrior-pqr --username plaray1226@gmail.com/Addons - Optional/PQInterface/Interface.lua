----[[ Ini ]]------------------------------------------------------------------------------------------------------------------
local AddOnName, Env = ... local ADDON = Env[1] 
local D = ADDON.development
----[[ Ace Ini ]]--------------------------------------------------------------------------------------------------------------
local AceConfigRegistry	= LibStub("AceConfigRegistry-3.0")
----[[ Lua Ini ]]--------------------------------------------------------------------------------------------------------------
local select, unpack						= select, unpack
local type	 								= type
local sub, find, format 				= string.sub, string.find, string.format
local floor, ceil, min, max			= math.floor, math.ceil, math.min, math.max
----[[ WoW Ini ]]--------------------------------------------------------------------------------------------------------------
local GetSpellInfo, GetTime  = GetSpellInfo, GetTime


----[[ Locals ]]---------------------------------------------------------------------------------------------------------------
local rotation, ability, rotationMode
----[[ Interface Scripts ]]----------------------------------------------------------------------------------------------------
local function interface_OnEnter(self,...)
	if self.drag then return end	
	self.anchor,self.yOffset = ADDON:GetTTAnchor(self)	
	self.showTT = true
	self:UpdateTT()
end
local function interface_OnLeave(self,...)
	self.showTT = false
	GameTooltip:Hide()
end
local function interface_OnDragStart(self,...)
	self.drag = true
	self.showTT = false
	GameTooltip:Hide()	
	self:StartMoving()		
end
local function interface_OnDragStop(self,...)
	self.drag = false
	self:StopMovingOrSizing()
	self:SavePosition()	
end
local function interface_OnDoubleClick(self,...)
	self.showTT = false
	GameTooltip:Hide()
	ADDON.db.profile.abilityLog.show = not ADDON.db.profile.abilityLog.show
	ADDON.abilityLog:Update()	
	AceConfigRegistry:NotifyChange(AddOnName)	
end
local function interface_OnMouseWheel(self,delta)	
	--ADDON.options.args.general.args.rows.min = 200
	--ADDON.options.args.general.args.rows.max = 600	
	--ADDON.options.args.general.args.rows.step = 10	
	
	if delta > 0 then		
		delta = min(ADDON.db.profile.interface.width + 10, 600 ) -- mays well recycle delta as its orignal value is no longer needed
	else
		delta = max(ADDON.db.profile.interface.width - 10, 200 )
	end
	ADDON.db.profile.interface.width = delta
	self:Update()
	AceConfigRegistry:NotifyChange(AddOnName)	
end
local function interruptLight_OnHide(self,...)
	self:SetWidth(.00001)	
end
local function interruptLight_OnShow(self,...)
	self:SetWidth(self.width)	
end
local function customText_OnTimer(self)
	UIFrameFadeOut(self.text, 1, 1, 0)	
end


----[[ Interface Methods ]]----------------------------------------------------------------------------------------------------
local methods = {	
	['SetPosition'] = function(self)
		self:ClearAllPoints()		
		if self.db.left and self.db.bottom then
			self:SetPoint("BOTTOMLEFT",self.db.left,self.db.bottom)
		else			
			self:SetPoint("CENTER")
			local left,bottom = ceil(self:GetLeft()), ceil(self:GetBottom())	
			self:ClearAllPoints()
			self:SetPoint("BOTTOMLEFT",left,bottom)
		end		
	end,
	['SavePosition'] = function(self)		
		self.db.left		= ceil(self:GetLeft())
		self.db.bottom		= ceil(self:GetBottom())	
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT",self.db.left,self.db.bottom)
	end,
	['Update'] = function(self)
		if not self.db.customText then self.customText:Hide() end				
		self:SetSize(self.db.width,self.customText:IsVisible() and self.customTextHeight + 1 + self.statusBarHeight + 6 or self.statusBarHeight + 6)		
		self:SetPosition()
		if not self.db.interruptLight then self.interruptLight:Hide() else self.interruptLight:Show() end
		if not self.db.statusIconCount then self.statusIconCount:Hide() else self.statusIconCount:Show() end
		
	end,	
	['UpdateTT'] = function(self)		
		if not self.showTT then return end		
		GameTooltip:SetOwner(self, self.anchor, 0, self.yOffset) 
		GameTooltip:AddLine('PQInterface Remote',0,.66,1)
		if ADDON.rotations and ADDON.rotations[1] then
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine("Rotation 1:",format("%s|cff00aaff %s",ADDON.rotations[1].rotation,ADDON.rotations[1].author), 0, .66, 1, 1, 1,1)	
			GameTooltip:AddDoubleLine("Rotation 2:",format("%s|cff00aaff %s",ADDON.rotations[2].rotation,ADDON.rotations[2].author), 0, .66, 1, 1, 1,1)	
			GameTooltip:AddDoubleLine("Rotation 3:",format("%s|cff00aaff %s",ADDON.rotations[3].rotation,ADDON.rotations[3].author), 0, .66, 1, 1, 1,1)	
			GameTooltip:AddDoubleLine("Rotation 4:",format("%s|cff00aaff %s",ADDON.rotations[4].rotation,ADDON.rotations[4].author), 0, .66, 1, 1, 1,1)	
			GameTooltip:AddDoubleLine("Interrupt:" ,format("%s|cff00aaff %s",ADDON.rotations[5].rotation,ADDON.rotations[5].author), 0, .66, 1, 1, 1,1)	
		end
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine("Mouse Wheel:","Adjust Width", 0, .66, 1, 1, .83, 0)		
		GameTooltip:AddDoubleLine("Double Click:","Toggle Ability Log", 0, .66, 1, 1, .83, 0)
		GameTooltip:Show()
	end,
	['SetStatusText']	 = function(self,text,color)		
		if not text then return end  --fail silently		
		color = color or "red"  
		self.statusText:SetText(text)			
		self.statusText:SetTextColor(unpack(ADDON.colors[color]))			
	end,
	['SetStatusAblility'] = function(self,ability,mode,rotation,spellID)					
		local c = ADDON.colors[mode=="auto" and "green" or mode=="manual" and "orange" or mode=="interrupt" and "blue"]
		if ability then 
			self.statusText:SetFormattedText("|cff%02x%02x%02x%s: |cffe5e5e5%s",c[1]*255,c[2]*255,c[3]*255,rotation,ability)			
			self:SetStatusIconCount(1)
		else 
			self.statusText:SetFormattedText("|cff%02x%02x%02x%s",c[1]*255,c[2]*255,c[3]*255,rotation)			
			self:SetStatusIconCount()
		end		
		if spellID then
			self:SetStatusIcon(select(3,GetSpellInfo(spellID == 0 and 4038 or spellID)))
		else
			
		end						
	end,
	['Standby'] = function(self)
		self:SetStatusIconCount(nil)
		self:SetStatusText("PQR on Standby.","blue")		
		self:SetStatusIcon()		
	end,
	['PowerUp'] = function(self)
		self:SetStatusIconCount(nil)
		self:SetStatusText("PQR on Standby.","blue")		
		self:SetStatusIcon()
		self:setIconMode(true)
		ADDON.abilityLog:setIconMode(true)		
	end,
	['PowerDown'] = function(self)
		self:SetStatusIconCount(nil)
		self:SetStatusText("PQR Unloaded.","red")
		self:SetStatusIcon()	
		self:setIconMode()
		ADDON.abilityLog:setIconMode()	
	end,
	['SetStatusIconCount'] = function(self,count)		
		self.statusIconCount:SetText(count==0 and nil or count)
	end,
	['SetStatusIcon'] = function(self,iconPath)
		if iconPath then 
			self.statusIcon.icon:SetTexCoord(.08, .92, .08, .92)
		else
			iconPath = ADDON.mediaPath.."PQRIconOn"
			self.statusIcon.icon:SetTexCoord(0,.59375,0,.59375)
		end		
		self.statusIcon.icon:SetTexture(iconPath)
	end,
	['SetInterruptLight'] = function(self,color)		
		if color == "green" then
			self.interruptLight.icon:SetTexCoord(ADDON:GetIconCoords(3,1))
		elseif color == "blue" then
			self.interruptLight.icon:SetTexCoord(ADDON:GetIconCoords(1,1))
		else -- off (red), anything else passed to color 					
			self.interruptLight.icon:SetTexCoord(ADDON:GetIconCoords(2,1))
		end
	end,
	['SetInterruptLight'] = function(self,color)		
		if color == "green" then
			self.interruptLight.icon:SetTexCoord(ADDON:GetIconCoords(3,1))
		elseif color == "blue" then
			self.interruptLight.icon:SetTexCoord(ADDON:GetIconCoords(1,1))
		else -- off (red), anything else passed to color 					
			self.interruptLight.icon:SetTexCoord(ADDON:GetIconCoords(2,1))
		end
	end,
	['SetCustomText'] = function(self,text,color,fadeOut)		
		if not self.customText:IsVisible() then self.customText:Show() self:Update() end	
		color = color and ADDON:Pack(ADDON:Hex2Color(color)) or ADDON.colors.purple		
		UIFrameFadeRemoveFrame(self.customText.text)
		self.customText.text:SetTextColor(color[1],color[2],color[3])	
		self.customText.text:SetText(text)
		ADDON:CancelTimer(self.customText.timer, true)
		if fadeOut then		
			self.customText.timer = ADDON:ScheduleTimer(customText_OnTimer, (fadeOut and type(fadeOut)=="number" and fadeOut or 10),self.customText)	
		end
	end,	
	['setIconMode'] = function(self,on)
		if on then 			
			UIFrameFadeOut(self.statusIcon.iconOff, 1, self.statusIcon.iconOff:GetAlpha(), 0)			
		else
			UIFrameFadeIn(self.statusIcon.iconOff, 1, self.statusIcon.iconOff:GetAlpha(), 1)
		end
	end, 
}
----[[ Interface Constructor ]]-------------------------------------------------------------------------------------------------
function ADDON:ConstructInterface()
	local lightWidth 			= 15
	local statusBarHeight	= 19
	local customTextHeight	= 16
	
	local interface = CreateFrame("Button",nil,UIParent)
	interface:SetFrameStrata('HIGH')
	interface:SetFrameLevel(10)	
	interface:SetMovable(true)
	interface:EnableMouse(true)
	interface:EnableMouseWheel(true)	
	interface:RegisterForDrag("LeftButton")
	interface:SetScript("OnDragStart", interface_OnDragStart)
	interface:SetScript("OnDragStop", interface_OnDragStop)
	interface:SetScript("OnDoubleClick", interface_OnDoubleClick)
	interface:SetScript("OnEnter", interface_OnEnter) 
	interface:SetScript("OnLeave", interface_OnLeave) 
	interface:SetScript("OnMouseWheel", interface_OnMouseWheel) 			
	
	local statusBar = CreateFrame("Frame",nil,interface)
	statusBar:SetHeight(statusBarHeight)
	statusBar:SetPoint("TOPLEFT",3,-3)
	statusBar:SetPoint("TOPRIGHT",-3,-3)	
		
	local statusIcon = CreateFrame("Frame",nil,statusBar)
	statusIcon:SetWidth(statusBar:GetHeight()) 
	statusIcon:SetPoint("TOPLEFT") 
	statusIcon:SetPoint("BOTTOMLEFT")	
	statusIcon.icon = statusBar:CreateTexture(nil,'BACKGROUND')
	statusIcon.icon:SetAllPoints(statusIcon) 
	statusIcon.icon:SetTexCoord(.08, .92, .08, .92)	
	statusIcon.iconOff = statusBar:CreateTexture(nil,'BACKGROUND',nil,1)
	statusIcon.iconOff:SetAllPoints(statusIcon) 
	statusIcon.iconOff:SetTexCoord(0,.59375,0,.59375)
	statusIcon.iconOff:SetTexture(ADDON.mediaPath.."PQRIconOff")
	
	local statusIconCount = statusIcon:CreateFontString(nil,"OVERLAY",'PQIFont_Intelligent')
	statusIconCount:SetPoint("CENTER",1,1)		
	
	local interruptLight = CreateFrame("Frame",nil,statusBar)
	interruptLight:SetPoint("TOPRIGHT",-5,0) 
	interruptLight:SetPoint("BOTTOMRIGHT",-5,0)
	interruptLight:SetWidth(lightWidth) interruptLight.width = lightWidth	
	interruptLight:SetScript("OnHide", interruptLight_OnHide)
	interruptLight:SetScript("OnShow", interruptLight_OnShow)
	interruptLight.icon = interruptLight:CreateTexture(nil)
	interruptLight.icon:SetTexture(ADDON.mediaPath.."PQRLights")
	interruptLight.icon:SetSize(16,16)
	interruptLight.icon:SetPoint("TOPLEFT",2,-2) 		
	
	local statusText = statusBar:CreateFontString(nil,"OVERLAY",'PQIFont_Intelligent')
	statusText:SetPoint("TOPLEFT",statusIcon,"TOPRIGHT",6,0) 
	statusText:SetPoint("BOTTOMRIGHT",interruptLight,"BOTTOMLEFT",-4,2)	
	statusText:SetJustifyH("LEFT")
	statusText:SetWordWrap(false)		
	
	local customText = CreateFrame("Frame",nil,interface)
	customText:SetPoint("TOPLEFT",3,-3 - statusBarHeight - 1)
	customText:SetPoint("TOPRIGHT",-3,-3 - statusBarHeight - 1)
	customText:SetHeight(customTextHeight)	
	customText:Hide()
	customText.text = customText:CreateFontString(nil,"OVERLAY",'PQIFont_Intelligent')
	customText.text:SetPoint("BOTTOMLEFT",6,4) 
	customText.text:SetPoint("BOTTOMRIGHT",-4,4)
	customText.text:SetJustifyH("CENTER")
	customText.text:SetJustifyV("BOTTOM")
	customText.text:SetWordWrap(false)	
	
	-----------------------------------------------------------------------
	interface.statusBar 			= statusBar	
	interface.interruptLight	= interruptLight	
	interface.statusIcon 		= statusIcon
	interface.statusIconCount 	= statusIconCount	
	interface.statusText 		= statusText	
	interface.customText 		= customText
		
	interface.db 					= self.db.profile.interface
	interface.statusBarHeight 	= statusBarHeight
	interface.customTextHeight = customTextHeight
		
	-----------------------------------------------------------------------
	for method, func in pairs(methods) do
		interface[method] = func
	end	
	-----------------------------------------------------------------------		
	ADDON:SkinInterface(interface)
	interface:Update()
	interface:SetStatusText("PQR not Loaded.","red")
	interface:SetStatusIcon()
	interface:SetInterruptLight("red")
	return interface
end