----[[ Ini ]]------------------------------------------------------------------------------------------------------------------
local AddOnName, Env = ...
local ADDON = LibStub("AceAddon-3.0"):NewAddon(AddOnName,'AceHook-3.0',"AceConsole-3.0","AceEvent-3.0","AceTimer-3.0")
Env[1], _G[AddOnName] = ADDON, ADDON
ADDON.mediaPath = [[Interface\AddOns\]]..AddOnName..[[\media\]]
----[[ Dev Ini ]]--------------------------------------------------------------------------------------------------------------
ADDON.development = _DiesalDevelopment or {}
local index = { __index = function(t, k) return function() return end end }
setmetatable(ADDON.development,index)
local D = ADDON.development
----[[ Lua Ini ]]--------------------------------------------------------------------------------------------------------------
local print, tostring, tonumber	= print, tostring, tonumber
local sub, find, format 			= string.sub, string.find, string.format
local floor, modf 					= math.floor, math.modf
local remove 							= table.remove


----[[ Fonts ]]----------------------------------------------------------------------------------------------------------------
CreateFont("PQIFont_Standard55")
CreateFont("PQIFont_Intelligent")
PQIFont_Standard55:SetFont( ADDON.mediaPath..[[Standard0755.ttf]], 8, "OUTLINE, MONOCHROME" )
PQIFont_Intelligent:SetFont( ADDON.mediaPath..[[FFF Intelligent Thin Condensed.ttf]], 8, "OUTLINE, MONOCHROME" )
----[[ ADDON API ]] -----------------------------------------------------------------------------------------------------------
function ADDON:Print(s,...)
	if not s then return end
	print(format("|cffffff00<|cff00aaff%s|cffffff00>|r %s",AddOnName,s))
	return self:Print(...)
end
function ADDON:Hex2Color(value)
	if not value or type(value) == "table" then return value end 
	local rhex, ghex, bhex = sub(value, 1, 2), sub(value, 3, 4), sub(value, 5, 6)
	return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end
function ADDON:Pack(...)
	local t = {}
	for i=1 ,select('#',...) do
		t[i] = select(i,...)
	end	
   return t
end
function ADDON:GetIconCoords(iconX,iconY,iconSize,HozizontalTextureSize,VerticalTextureSize)
	iconSize = iconSize or 16
	HozizontalTextureSize 	= HozizontalTextureSize or 128
	VerticalTextureSize 		= VerticalTextureSize 	or 16
	
	local left  	= (iconX * iconSize - iconSize) / HozizontalTextureSize
	local right 	= (iconX * iconSize) / HozizontalTextureSize
	local top 		= (iconY * iconSize - iconSize) / VerticalTextureSize
	local bottom	= (iconY * iconSize) / VerticalTextureSize
	
	return left,right,top,bottom
end
function ADDON:Round(num,base)
	local under, over, overV, underV 
	base = base or 1
	under = floor(num/base)
	over = floor(num/base) + 1
	underV = -(under - num/base)
	overV = over - num/base
	if (overV > underV) then
		return under * base
	else
		return over * base
	end
end
function ADDON:FormatGetTime(num)
	if num == 0 then return 0,0,0,0 end
	local seconds,ms = modf(num)
	local c =  ADDON.colors.blue
	local d = format("%02.f", floor(num/86400))
	local h = format("%02.f", floor(num/3600 - (d*24)))
	local m = format("%02.f", floor(num/60 - (h*60) -(d*1440)));
	local s = format("%02.f", floor(num - (m*60) - (h*3600) - (d*86400) ));
	s = s + ms
	local t = format("|cff%02x%02x%02x%s:%s:|r%02.3f",c[1]*255,c[2]*255,c[3]*255, h,m,s)
	return t
end
function ADDON:GetTTAnchor(frame)
	local x, y = frame:GetCenter()
	local screenWidth = GetScreenWidth()
	local screenHeight = GetScreenHeight()
	local point,yOffset
	
	if not x then return "ANCHOR_TOP", 5 end
	
	if (x > (screenWidth / 4) and x < (screenWidth / 4)*3) and y > (screenHeight / 4)*3 then
		point,yOffset = "ANCHOR_BOTTOM", -5 -- TOP
	elseif x < (screenWidth / 4) and y > (screenHeight / 4)*3 then
		point,yOffset = "ANCHOR_BOTTOM", -5 -- TOPLEFT
	elseif x > (screenWidth / 4)*3 and y > (screenHeight / 4)*3 then
		point,yOffset = "ANCHOR_BOTTOM", -5 -- TOPRIGHT
	else
		point,yOffset = "ANCHOR_TOP", 5 		
	end
	return point,yOffset
end
function ADDON:GarbageCollection()	
	collectgarbage('collect')	
end
----[[ ADDON Constants ]]------------------------------------------------------------------------------------------------------
ADDON.defaultIcon = select(3,GetSpellInfo(4038))
ADDON.colors = {	
	blue 		= ADDON:Pack(ADDON:Hex2Color('00a8ff')),
	red 		= ADDON:Pack(ADDON:Hex2Color('ff0000')),
	green 	= ADDON:Pack(ADDON:Hex2Color('2aff00')),
	orange 	= ADDON:Pack(ADDON:Hex2Color('ffaa00')),
	purple 	= ADDON:Pack(ADDON:Hex2Color('8066ff')),	
}