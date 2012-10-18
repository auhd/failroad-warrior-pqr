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
local function constructTextField(name,text,parent,anchor,width,header)
	parent[name] = parent:CreateFontString(nil,"OVERLAY",'PQIFont_Intelligent')
	parent[name]:SetText(text)
	parent[name]:SetJustifyH("LEFT")
	parent[name]:SetWordWrap(false)	
	parent[name]:SetWidth(width)
	if header then parent[name]:SetTextColor(unpack(ADDON.colors.blue)) end
	if name == 'field1' then parent[name]:SetPoint("TOPLEFT",anchor,"TOPRIGHT",5,-5) 
	else parent[name]:SetPoint("LEFT",anchor,"RIGHT",6,0) end
end
----[[ AbilityLog Scripts ]]---------------------------------------------------------------------------------------------------
local function abilityLog_OnDragStop(self,...)
	self:StopMovingOrSizing()
	self:SavePosition()	
end
local function abilityLog_OnMouseWheel(self,delta)	
	--ADDON.options.args.general.args.rows.min = 10
	--ADDON.options.args.general.args.rows.max = 40	
	if not ADDON.db.profile.abilityLog.mouseWheel then return end
	if delta > 0 then		
		delta = min(ADDON.db.profile.abilityLog.rows + 1, 40 ) -- mays well recycle delta as its orignal value is no longer needed
	else
		delta = max(ADDON.db.profile.abilityLog.rows - 1, 10 )
	end
	ADDON.db.profile.abilityLog.rows = delta
	self:Update()
	AceConfigRegistry:NotifyChange(AddOnName)	
end
local function row_OnEnter(self,...)
	self.TTShow = true
	self.obj:UpdateTT()	
end
local function row_OnLeave(self,...)
	self.TTShow = false
	GameTooltip:Hide()	
end

----[[ AbilityLog Methods ]]---------------------------------------------------------------------------------------------------
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
		if self.db.show then self:Show() else self:Hide() end	
		--adjust height	
		self:SetHeight(((self.rowHeight+1)*self.db.rows) + 25)	
		ADDON.abilitiesLog:SetCache(self.db.rows)		
		-- update rows			
		self:DrawRows()
		self:SetPosition()
		self:RowsMouseEnabled(self.db.tooltips)
		self:RefreshData(ADDON.abilitiesLog)		
	end,
	['UpdateTT'] = function(self)
		if not self.db.tooltips then return end
		local data
		for i=1,self.db.rows do			
			if self.content['row'..i].TTShow and self.content['row'..i].data then data = self.content['row'..i].data break end				
		end
		if not data then return end		
		
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR" , 0, 0) 
		GameTooltip:AddLine('PQInterface Ability Log',0,.66,1)
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine("Spell:",data.spell, 0, .66, 1, 1, 1,1)
		GameTooltip:AddDoubleLine("SpellID:",data.spellID, 0, .66, 1, 1, 1,1)
		GameTooltip:AddDoubleLine("Ability:",data.abilityName, 0, .66, 1, 1, 1,1)
		GameTooltip:AddDoubleLine("Rotation:",format("%s|cff00aaff %s",data.rotation,data.author), 0, .66, 1, 1, 1,1)	
		GameTooltip:AddDoubleLine("PQR Mode:",data.mode, 0, .66, 1, 1, 1,1)
		GameTooltip:AddDoubleLine("Execute Count:",data.executeCount, 0, .66, 1, 1, 1,1)
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine("Mouse Wheel:","Adjust height", 0, .66, 1, 1, .83, 0)		
		GameTooltip:Show()
	end,
	['DrawRows'] = function(self)			
		if self.drawnRows < self.db.rows then  -- need to draw more rows
			for i=1, self.db.rows do
				if i > self.drawnRows then -- create a new row
					self:ConstructRow(i)
					self.drawnRows = i					
				end
			end
		elseif self.drawnRows > self.db.rows then -- need to hide rows
			for i=1, self.drawnRows do
				if i > self.db.rows then -- hide row
					self.content['row'..i]:Hide()					
				else -- make sure row is visible									
					self.content['row'..i]:Show()			
				end				
			end
		else 			
			self.content['row'..self.drawnRows]:Show()					
		end		
	end,
	['ConstructRow'] = function(self,rowNumber)
		--if self.content['row'..rowNumber] then self.content['row'..rowNumber]:Show() return end
		self.content['row'..rowNumber] = CreateFrame("Frame",nil,self.content)
		local row = self.content['row'..rowNumber]
		row:SetHeight(self.rowHeight)		
		row:SetPoint("LEFT",1,0) row:SetPoint("RIGHT",-1,0)
		if rowNumber==1 then	row:SetPoint("TOP",0,-1)
		else row:SetPoint("TOP",self.content['row'..rowNumber-1],"BOTTOM",0,-1)	end
		row.icon = row:CreateTexture(nil,'BORDER',0)
		row.icon:SetWidth(self.rowHeight)
		row.icon:SetPoint("TOPLEFT")
		row.icon:SetPoint("BOTTOMLEFT")
		row.icon:SetTexCoord(.08, .92, .08, .92)
		row.count = row:CreateFontString(nil,"OVERLAY",'PQIFont_Intelligent')
		row.count:SetPoint("CENTER",row.icon,"CENTER",1,1)
		row:EnableMouse(true)
		--row:EnableMouseWheel(true)
		row:SetScript("OnEnter", row_OnEnter) 
		row:SetScript("OnLeave", row_OnLeave)
		--row:SetScript("OnMouseDown", function() self:OnMouseDown("LeftButton", true) end)
		 
		
			
		
		constructTextField('field1',nil,row,row.icon,self.spellColoumnWidth)	
		constructTextField('field2',nil,row,row.field1,self.abilityColoumnWidth)
		constructTextField('field3',nil,row,row.field2,self.startColoumnWidth)
		constructTextField('field4',nil,row,row.field3,self.castColoumnWidth)		
		ADDON:SkinRow(row)
		row.obj = self
	end,
	['RefreshData'] = function(self)
		self:ClearData()
		for i=1, self.db.rows do	
			local row = self.content['row'..i]
			if ADDON.abilitiesLog[i] then
				row.data = ADDON.abilitiesLog[i] 							
				row.icon:SetTexture(select(3,GetSpellInfo(row.data.spellID)))
				row.count:SetText(row.data.executeCount)
				row.field1:SetText(row.data.spell)
				row.field2:SetText(row.data.abilityName)
				row.field3:SetText(row.data.start)
				row.field4:SetText(row.data.cast)				
			end
			--row.feild1
		end
		self:UpdateTT()	
	end,
	['ClearData'] = function(self,data)
		--dump("ablitylog",data)	
		for i=1, self.db.rows do
			if self.content['row'..i].data then 
				local row = self.content['row'..i]				
				row.icon:SetTexture(nil)
				row.count:SetText(nil)
				row.field1:SetText(nil)
				row.field2:SetText(nil)
				row.field3:SetText(nil)
				row.field4:SetText(nil)
				row.data = nil
			end		
		end	
	end,
	['RowsMouseEnabled'] = function(self,enable)		
		for i=1, self.drawnRows do
			self.content['row'..i]:EnableMouse(enable)			
		end		
	end,
	['setIconMode'] = function(self,on)
		if on then 			
			UIFrameFadeOut(self.header.iconOff, 1, self.header.iconOff:GetAlpha(), 0)			
		else
			UIFrameFadeIn(self.header.iconOff, 1, self.header.iconOff:GetAlpha(), 1)
		end
	end,
}
----[[ AbilityLog Constructor ]]-----------------------------------------------------------------------------------------------
function ADDON:ConstructLog()
	local width 					= 560	
	local rowHeight 				= 19	
	local spellColoumnWidth 	= 150	-5
	local abilityColoumnWidth 	= 200 -5
	local startColoumnWidth 	= 90	-5
	local castColoumnWidth 		= 90	-5	
	
	local abilityLog = CreateFrame("Frame",nil,UIParent)
	abilityLog:SetFrameStrata('HIGH')
	abilityLog:SetWidth(width) 	 
	abilityLog:SetMovable(true)
	abilityLog:EnableMouse(true)	
	abilityLog:EnableMouseWheel(true)	
	abilityLog:RegisterForDrag("LeftButton")
	abilityLog:SetScript("OnDragStart", abilityLog.StartMoving)
	abilityLog:SetScript("OnDragStop", abilityLog_OnDragStop) 	
	abilityLog:SetScript("OnMouseWheel", abilityLog_OnMouseWheel) 	
	
	local header = CreateFrame("Frame",nil, abilityLog)
	header:SetHeight(rowHeight)
	header:SetPoint("TOPLEFT",3,-3)
	header:SetPoint("TOPRIGHT",-3,-3)	
	
	header.icon = header:CreateTexture(nil,'BACKGROUND',nil,1)
	header.icon:SetWidth(rowHeight)
	header.icon:SetPoint("TOPLEFT")
	header.icon:SetPoint("BOTTOMLEFT")
	header.icon:SetTexture(ADDON.mediaPath.."PQRIconOn")
	header.icon:SetTexCoord(0,.59375,0,.59375)
	header.iconOff = header:CreateTexture(nil,'BACKGROUND',nil,2)
	header.iconOff:SetWidth(rowHeight)
	header.iconOff:SetPoint("TOPLEFT")
	header.iconOff:SetPoint("BOTTOMLEFT")
	header.iconOff:SetTexture(ADDON.mediaPath.."PQRIconOff")
	header.iconOff:SetTexCoord(0,.59375,0,.59375)
	
	constructTextField('field1',"Spell",header,header.icon,spellColoumnWidth,true)
	constructTextField('field2',"Ability Name",header,header.field1,abilityColoumnWidth,true)
	constructTextField('field3',"Start Time",header,header.field2,startColoumnWidth,true)
	constructTextField('field4',"Cast Time",header,header.field3,castColoumnWidth,true)
	
	local content = CreateFrame("Frame",nil, abilityLog)
	content:SetPoint("TOPLEFT",header,"BOTTOMLEFT",-1,0)
	content:SetPoint("BOTTOMRIGHT",-2,2) 	
	
	-----------------------------------------------------------------------
	abilityLog.statusBar 			= statusBar	
	abilityLog.header					= header	
	abilityLog.content 				= content
		
	abilityLog.db 						= self.db.profile.abilityLog
	abilityLog.rowHeight				= rowHeight
	abilityLog.spellColoumnWidth	= spellColoumnWidth
	abilityLog.abilityColoumnWidth= abilityColoumnWidth
	abilityLog.startColoumnWidth	= startColoumnWidth
	abilityLog.castColoumnWidth	= castColoumnWidth
	abilityLog.drawnRows				= 0
	-----------------------------------------------------------------------
	for method, func in pairs(methods) do
		abilityLog[method] = func
	end
	-----------------------------------------------------------------------
	ADDON:SkinAblityLog(abilityLog)
	abilityLog:Update()	
	return abilityLog	
end

