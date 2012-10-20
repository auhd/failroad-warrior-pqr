if not PQR_LoadedDataFile then
	PQR_LoadedDateFile = 1
	print("|cffFF6EB4--Failroad data file--|cffffffff")
elseif PQR_LoadedDataFile then
	print("|cffFF6EB4--Reloading Data--|cffffffff")
end

local PvPslows = {
				-- DK
					45524,
					50435,
				-- DRUID
					58180,
					102355,
				-- HUNTER
					5116,
					72217,
				-- MAGE
					7302,
					116,
					120,
					44614,
				-- PRIEST
					124468,
					15407,
				-- ROGUE
					26679,
					3408,
				-- SHAMAN
					8056,
				-- WARLOCK
					18223,
				-- WARRIOR
					12323,
					1715,
				-- PALADIN
					110300,
				-- Monk
					116095
				}
				
local immuneToSlowID = {
					--Hand of Freedom
					1044,
					--Dispersion
					47585,
					--Avatar
					107574,
					--Master's Call
					54216,
					--WindWalk Totem
					114896,
					--Bladestorm
					46924
				}
							
local reflectID = { 
	5782, -- Fear
	33786, -- Cyclone
	28272, -- Pig Poly
	118, -- Sheep Poly
	61305, -- Cat Poly
	61721, -- Rabbit Poly
	61780, -- Turkey Poly
	28271, -- Turtle Poly
	51514, -- Hex
	51505, -- Lava Burst
	339, -- Entangling Roots
	30451, -- Acrane Blast
	605 -- Mind Control
}

local disarmID = {
				-- Paladin
				31884,
				-- Warrior
				18499,
				1719,
				46924, 
				--Bloodlust
				2825, 
				32182,
				--Rogue
				51713,
				--DK
				51271,
				--OrcRacial 
				33702, 
				20572, 
				33697,
				--PvP Trinket 
				99740,
				--Mage
				12472
}

local immuneID = {
110700, --Divine Shield
1022, --Hand of Protection
45438, --Ice Block
31224,--Cloak of Shadows
19263, --Deterrence
97417--BrittleBarrier
}

local apBuff = {
57330,--Horn of Winter
19506--Trueshot Aura
}

function hasApBuff()
for i=1,#apBuff do
	if UnitBuffID("player",apBuff[i])
		then
			return true
		end
	end
end
	

function inCombatAndMelee()
if UnitAffectingCombat("player")
and IsSpellInRange(GetSpellInfo(78),"target") == 1
and UnitExists("target")
and UnitCanAttack("player","target")
	then
		return true
	end
end

function inCombat()
if UnitAffectingCombat("player")
	then
		return true
	end
end

function getHp(unit)
if UnitExists(unit)
	then
		return 100 * UnitHealth(unit) / UnitHealthMax(unit)
	end
end


function isSlowed(unit)
for i=1,#PvPslows do
	if UnitDebuffID(unit,PvPslows[i])
		then
			return true
		end
	end
end

function immuneToSlow(unit)
for i=1,#immuneToSlowID do
	if UnitBuffID(unit,immuneToSlowID[i])
		then
			return true
		end
	end
end

function spellReflect(unit)
	if UnitCastingInfo(unit)
	and UnitIsUnit("player",unit.."target")
	and UnitIsEnemy("player", unit)
	and IsSpellInRange(GetSpellInfo(57755), unit) == 1
	and select(2,GetSpellCooldown(23920)) == 0
	and not UnitBuffID("player",23920)
	then
		for i=1, #reflectID do
			if UnitCastingInfo(unit) == GetSpellInfo(reflectID[i])
				then
				local _, _, _, _,  startTimer, endTimer = UnitCastingInfo(unit)
				local timeSinceStart = (GetTime() * 1000 - startTimer) / 1000
				local castTime = endTimer - startTimer
				local currentPercent = timeSinceStart / castTime * 100000
					if currentPercent > 25 
						then
								return 1
						end
					if currentPercent <= 25
						then
								return 2
						end
				
				end
		end
	end
end


function shouldDisarm(unit)
	for i=1,#disarmID do
		if UnitBuffID(unit,disarmID[i])
			then 
				return true
			end	
		end
end

function isImmune(unit)
	for i=1,#immuneID do
		if UnitBuffID(unit,immuneID[i])
			then
				return true
			end
		end
end
