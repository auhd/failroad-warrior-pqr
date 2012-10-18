----[[ Ini ]]------------------------------------------------------------------------------------------------------------------
local AddOnName, Env = ... local ADDON = Env[1] 
local D = ADDON.development
----[[ Ace Ini ]]--------------------------------------------------------------------------------------------------------------
----[[ Lua Ini ]]--------------------------------------------------------------------------------------------------------------
----[[ WoW Ini ]]--------------------------------------------------------------------------------------------------------------


----[[ Default Settings ]]-----------------------------------------------------------------------------------------------------
ADDON.defaults = {
	global = {
		enabled = true,
		locked = false,
		minimap = {
			hide = false,
		},		
	},
	profile = {
		interface = {
			statusIconCount = true,	
			interruptLight = true,
			width = 300,
			customText = true,			
		},
		abilityLog = {
			show = false,
			rows = 15,
			mouseWheel = true,
			tooltips = true,			
		},				
	},		
}

----[[ Options ]]---------------------------------------------------------------------------------------------------------------
ADDON.options = {
	type = "group",
	name = AddOnName,	
	args = {
		general = {
			order = 10,
			type = "group",
			name = "General Settings",
			cmdInline = true,
			get = GetGlobalOption,
			set = SetGlobalOption,
			args = {
				enabled = {
					order = 10,
					type = "toggle",
					name = "Enabled",
					handler = ADDON,
					get = "IsEnabled",						
					set = function(info,value)						
						ADDON.db.global.enabled = value
						if value then ADDON:Enable() else ADDON:Disable() end end,		
					width = "normal",				
            },
            minimap = {
					type = "toggle",
					name = "Minimap Button",
					order = 30,
					disabled = function() return not ADDON:IsEnabled() end,
					get = function() return not ADDON.db.global.minimap.hide end,
					set = function(info,value) ADDON.db.global.minimap.hide = not value; ADDON:Update() end,
					width = "normal",					
				},
				spacer = {
					order = 35,
					type = "description",
					name = " ",					
					width = "full",
				},
				remoteTitle = {
					order = 40,
					type = "description",
					name = "|cff00aaffRemote",
					fontSize = "large",
					width = "full",
				},				
				statusIconCount = {
					type = "toggle",
					name = "Execute Count",
					order = 50,
					desc = "Toggles the execute count for the current ablity on the remote. Hint: the number overlaying the spell icon.",
					disabled = function() return not ADDON:IsEnabled() end,
					get = function() return ADDON.db.profile.interface.statusIconCount end,
					set = function(info,value) ADDON.db.profile.interface.statusIconCount = value; ADDON.interface:Update() end,
					width = "normal",					
				},
				interruptLight = {
					type = "toggle",
					name = "Interrupt Light",
					order = 52,
					desc = "Toggles the Interrupt Indicator.",
					disabled = function() return not ADDON:IsEnabled() end,
					get = function() return ADDON.db.profile.interface.interruptLight end,
					set = function(info,value) ADDON.db.profile.interface.interruptLight = value; ADDON.interface:Update() end,
					width = "normal",					
				},
				interfaceWidth = {
					type = "range",
					name = "Width",
					order = 55,
					desc = "Sets the remotes width.",
					min = 200, max = 600, step = 10,
					disabled = function() return not ADDON:IsEnabled() end,
					get = function() return ADDON.db.profile.interface.width end,
					set = function(info,value) ADDON.db.profile.interface.width = value; ADDON.interface:Update() end,
					width = "normal",					
				},
				newLine = {
					order = 57,
					type = "description",
					name = "",					
					width = "full",
				},
				customText = {
					type = "toggle",
					name = "Custom Rotation Text",
					order = 58,
					desc = "Toggles the custom rotation text field, used by some rotations to update users on it's status. (this is hidden regardless of mode until custom text is received)",
					disabled = function() return not ADDON:IsEnabled() end,
					get = function() return ADDON.db.profile.interface.customText end,
					set = function(info,value) ADDON.db.profile.interface.customText = value; ADDON.interface:Update() end,
					width = "normal",					
				},
				spacer1 = {
					order = 59,
					type = "description",
					name = " ",					
					width = "full",
				},
				abilityLogTitle = {
					order = 60,
					type = "description",
					name = "|cff00aaffAbility Log",
					fontSize = "large",
					width = "full",
				},
				abilityLog = {
					order = 62,
					type = "toggle",
					name = "Ability Log",
					desc = "Toggles the Ability Log.",
					disabled = function() return not ADDON:IsEnabled() end,
					get = function() return ADDON.db.profile.abilityLog.show end,
					set = function(info,value) ADDON.db.profile.abilityLog.show = value; ADDON.abilityLog:Update() end,
					width = "normal",					
				},
				mouseWheel = {
					order = 64,
					type = "toggle",
					name = "Mouse Wheel",
					desc = "Allows use of the mouse wheel on the ability Log to adjust visible rows.",
					disabled = function() return not ADDON:IsEnabled() end,
					get = function() return ADDON.db.profile.abilityLog.mouseWheel end,
					set = function(info,value) ADDON.db.profile.abilityLog.mouseWheel = value end,
					width = "normal",					
				},
				rows = {
					type = "range",
					name = "Rows",
					desc = "Adjust Visible Rows for the ability Log.",
					order = 65,
					min = 10, max = 40, step = 1,
					disabled = function() return not ADDON:IsEnabled() end,
					get = function() return ADDON.db.profile.abilityLog.rows end,
					set = function(info,value) ADDON.db.profile.abilityLog.rows = value; ADDON.abilityLog:Update() end,
					width = "normal",					
				},
				newLine = {
					order = 67,
					type = "description",
					name = "",					
					width = "full",
				},
				tooltips = {
					order = 70,
					type = "toggle",
					name = "Tooltips",
					desc = "Toggle visibility of tooltips for the Ability Log",
					disabled = function() return not ADDON:IsEnabled() end,
					get = function() return ADDON.db.profile.abilityLog.tooltips end,
					set = function(info,value) ADDON.db.profile.abilityLog.tooltips = value  ADDON.abilityLog:Update() end,
					width = "normal",					
				},				
         },
		},
	},
}