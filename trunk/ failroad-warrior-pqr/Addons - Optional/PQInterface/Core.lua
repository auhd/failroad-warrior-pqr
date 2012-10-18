----[[ Ini ]]------------------------------------------------------------------------------------------------------------------
local AddOnName, Env = ... local ADDON = Env[1] 
local D = ADDON.development
----[[ Ace Ini ]]--------------------------------------------------------------------------------------------------------------
local LibDBIcon			= LibStub("LibDBIcon-1.0",true)
local AceDB					= LibStub("AceDB-3.0")
local AceDBOptions 		= LibStub("AceDBOptions-3.0")
local AceConfigRegistry	= LibStub("AceConfigRegistry-3.0")
local AceConfigDialog 	= LibStub("AceConfigDialog-3.0")
local LibDataBroker		= LibStub("LibDataBroker-1.1")
local LibDBIcon 			= LibStub("LibDBIcon-1.0",true)
----[[ Lua Ini ]]--------------------------------------------------------------------------------------------------------------
local select, print						= select, print
local type, tostring, tonumber		= type, tostring, tonumber
local getmetatable						= getmetatable
local sub, find, format 				= string.sub, string.find, string.format
local floor 								= math.floor
local remove 								= table.remove
----[[ WoW Ini ]]--------------------------------------------------------------------------------------------------------------
local GetSpellInfo, GetTime  = GetSpellInfo, GetTime

----[[ Locals  ]]---------------------------------------------------------------------------------------------------------------------
local statusText = {}

-- PQR_BotLoaded is not firing on subsequent bot loads.... 
--HACK--[
local function BotUnloaded_Hack()	
	ADDON.loaded = false		
end
local function BotLoaded_Hack()
	if not ADDON.loaded then
		ADDON.loaded = true	
		PQR_BotLoaded()				
	end	
end
--------]
local function ManualTimer()
	ADDON.executedAbilities:ClearAbilities()
	ADDON.interface:Standby()	
end
----[[ Value Objects]]---------------------------------------------------------------------------------------------------------
local rotations = {}
local abilitiesLog = {cache = 10}
local executedAbilities = {cache = 5}

setmetatable( rotations, {__index = {	
	['SetRotations'] = function(self,...)		
		local _,rotation,author
		for i=1,5 do		
			_,_,rotation,author = find(select(i,...),"^(.*) %((.-)%)$")				
			self[i] = {rotation = rotation or "|cffff0000not set", author = author or ""}		
		end
		ADDON.interface:UpdateTT(self)	
	end,	
}})
setmetatable( abilitiesLog, {__index = {	
	['SetCache'] = function(self,cache)
			if type(cache) ~="number" then return end
			self.cache = cache
			if #self > cache then
				local cut = #self - cache 
				for i = 1, cut do 
					remove(self,i)
				end
				if ADDON.abilityLog:IsVisible() then				
					ADDON.abilityLog:RefreshData()
				end			
			end
		end,
	['AddAbility'] = function(self,ability)							
		self[#self+1] = ability		
		if #self > self.cache then remove(self,1) end -- remove oldest entry iff array length exceeds allowed history
		if ADDON.abilityLog:IsVisible() then ADDON.abilityLog:RefreshData() end		
	end,	
}})
setmetatable( executedAbilities,{__index = {	
	-- runs everytime pqr sends an executed ability
	['Ability'] = function(self,abilityName,spellID,rotationNumber)			
		ADDON:CancelTimer(self.manualTimer, true)								-- clears the manual timer
		if rotationNumber < 6 and not rotations.auto then					-- if manual mode or not in auto mode then set a 10 sec timer for idle
			self.manualTimer = ADDON:ScheduleTimer(ManualTimer,10)
		end 	
		if rotations.rotationNumber ~= rotationNumber then					-- checks for a new mode then clears ablities
			self:ClearAbilities()
		end				
		rotations.rotationNumber = rotationNumber			
		local count = #self	
		-- check we havnt already logged the ability, increment the execute counter iff we have and return		
		if self[count] and self[count].abilityName == abilityName then			
			self[count].executeCount = self[count].executeCount + 1				
			ADDON.interface:SetStatusIconCount(self[count].executeCount)
			return
		end
				
		-- add a new ability
		local rotation, mode = rotations[rotationNumber].rotation, rotationNumber == 5 and "interrupt" or rotationNumber == 6 and "auto" or "manual"						
		local ability 	= select(3,find(abilityName,"^(.*) %((.-)%)$"))			
		self[count+1] = {
			abilityName 	= abilityName,
			spellID 			= spellID,
			spell				= GetSpellInfo(spellID),
			executeCount	= 1,
			start				= ADDON:FormatGetTime(GetTime()),
			mode				= mode,	
			rotation			= rotation,	
		}			
		if count > self.cache then remove(self,1) end -- remove oldest entry iff array length exceeds allowed cache
		-- set the remote to show the new ability in the interface		
		ADDON.interface:SetStatusAblility(ability,mode,rotation,spellID)			
	end,
	['LogAbility'] = function(self, spell, cast)		
		for i =1, #self do
			if self[i].spell==spell then
				self[i].abilityName, self[i].author = select(3,find(self[i].abilityName,"^(.*) %((.-)%)$"))
				self[i].cast = cast					
				abilitiesLog:AddAbility(self[i])				
				self:ClearAbilities(i)
				return
			end
		end
		-- only get here iff spellID = 0 in the ability or the spell was cast from outside the bot
	end,	
	['ClearAbilities'] = function(self,from)	
		from = from or #self		
		for i = from, 1, -1 do
			remove(self,i)
		end			
	end,	
}})
ADDON.executedAbilities	= executedAbilities
ADDON.rotations			= rotations
ADDON.abilitiesLog 		= abilitiesLog
----[[ Event Listeners ]]------------------------------------------------------------------------------------------------------
RegisterCVar("PQREventsEnabled",'1') -- enables PQR events to fire
function PQR_BotLoaded(...)
	ADDON.interface:PowerUp()		
	--HACK--[
	ADDON.loaded = true
	--------]	
end
function PQR_BotUnloaded(...)	
	ADDON.interface:PowerDown()	
	--HACK--[
	ADDON:ScheduleTimer(BotUnloaded_Hack,2)
	--------] 	
end
function PQR_Selections(...)	
	rotations:SetRotations(...)
	--HACK--[
	BotLoaded_Hack()	
	--------]
end
function PQR_RotationChanged(rotationName)		
	if rotationName then
		executedAbilities:ClearAbilities()
		rotations.auto = true 
		rotations[6] = {rotation = rotationName}
		
		ADDON.interface:SetStatusAblility(nil,"auto",rotationName)			
	else -- fired when exiting auto rotation mode
		rotations.auto = nil
		executedAbilities:ClearAbilities()
		ADDON.interface:Standby()				
	end	
end
function PQR_InterruptChanged(rotationName)	
	ADDON.interface:SetInterruptLight(rotationName and "green" or "red")	
end
function PQR_ExecutingAbility(abilityName, spellID, rotationNumber)
	-- test for left over CVars	
	if not abilityName or not rotationNumber or not rotations[1] or not spellID then return end
				
	executedAbilities:Ability( abilityName, spellID, rotationNumber == 0 and 6 or rotationNumber) 	
end
function PQR_Text(text,fadeOut,color)	
	if not ADDON.interface.db.customText then return end
	ADDON.interface:SetCustomText(text,color,fadeOut)	
end
function ADDON:UNIT_SPELLCAST_SUCCEEDED(event, unitID, spell, rank, lineID, spellID)		
	if unitID ~="player" then return end
	--D.P(event, unitID, spell, rank, lineID, spellID)
	local cast = ADDON:FormatGetTime(GetTime())	
	executedAbilities:LogAbility( spell, cast ) 	
	
end
-- cvar data probe
--function ADDON:RegisterCVar(...)
--  D.P("RegisterCVar",...)
--end
function ADDON:GetCVar(...)
  D.P("GetCVar",...)
end
function ADDON:SetCVar(...)
  D.P("SetCVar",...)
end
--ADDON:Hook('RegisterCVar',true)
--ADDON:Hook('GetCVar',true)
--ADDON:Hook('SetCVar',true)

----[[ ADDON Scripts ]]--------------------------------------------------------------------------------------------------------
local function Launcher_OnClick(self,button)
	if button == "LeftButton" then 
		if ADDON:IsEnabled() then ADDON:Disable() else ADDON:Enable() end
		AceConfigRegistry:NotifyChange(AddOnName)	
	else
		InterfaceOptionsFrame_OpenToCategory(ADDON.optionsFrame)		
	end
end
----[[ ADDON Methods ]]--------------------------------------------------------------------------------------------------------
function ADDON:OnInitialize()
	-- Database	
	self.db = AceDB:New("PQInterfaceDB", self.defaults, true);
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileUpdate")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileUpdate")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileUpdate")	
	
	-- Options
	self.options.args.profile = AceDBOptions:GetOptionsTable(self.db)
	self.options.args.profile.order = -10
	AceConfigRegistry:RegisterOptionsTable(AddOnName, ADDON.options)
	self.optionsFrame = AceConfigDialog:AddToBlizOptions(AddOnName, nil, nil, "general")	
	AceConfigDialog:AddToBlizOptions(AddOnName, "Profiles", AddOnName, "profile")
	-- DataBroker Launcher Plugin
	self.launcher = LibDataBroker:NewDataObject(AddOnName, 
	{
		type = "launcher",
		label = AddOnName,
		icon = ADDON.mediaPath.."PQRIcon",
		OnClick = Launcher_OnClick,		
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(AddOnName, 0, .66, 1)
			tooltip:AddLine(" ")			
			tooltip:AddDoubleLine("Left Click:","Toggle Addon", 0, .66, 1, 1, .83, 0)
			tooltip:AddDoubleLine("Right Click:","Open Config", 0, .66, 1, 1, .83, 0)

		end,      
	})
	-- Minimap button
	LibDBIcon:Register(AddOnName,self.launcher,self.db.global.minimap) 
	ADDON.interface 	= ADDON:ConstructInterface()
	ADDON.abilityLog 	= ADDON:ConstructLog()
	self:Print("v"..GetAddOnMetadata(AddOnName,"Version").." Loaded.")		
end
function ADDON:OnEnable() 
	self.garbageCollectionTimer = self:ScheduleRepeatingTimer('GarbageCollection', 100) 	
	self.interface:Show()
	self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')	
	self:Update()	
	self:Print("Enabled.")			
end
function ADDON:OnDisable()
	self:CancelTimer(self.garbageCollectionTimer, true)
	self:UnregisterAllEvents()
	self.interface:Hide()
	self.abilityLog:Hide()	
	self:Print("Disabled.")	
end
function ADDON:ProfileUpdate()
	self.db = AceDB:New("PQInterfaceDB", self.defaults, true);
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileUpdate")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileUpdate")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileUpdate")
	self:UpdateDatabasePointers()	
	self:Update()	
end
function ADDON:UpdateDatabasePointers()	
	self.interface.db		= self.db.profile.interface
	self.abilityLog.db	= self.db.profile.abilityLog
	
end
function ADDON:Update()
	-- Minimap icon	
	if self.db.global.minimap.hide then	LibDBIcon:Hide(AddOnName) else LibDBIcon:Show(AddOnName) end	
	self.interface:Update()
	self.abilityLog:Update()
end