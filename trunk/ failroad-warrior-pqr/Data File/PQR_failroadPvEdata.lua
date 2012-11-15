if not PQR_LoadedDataFile then
	PQR_LoadedDateFile = 1
	print("|cffFF6EB4--Failroad PVE data file--|cffffffff")
elseif PQR_LoadedDataFile then
	print("|cffFF6EB4--Reloading Data--|cffffffff")
end

--Variables--
custTars	= {"target","focus"}
local apBuff = {
57330,--Horn of Winter
19506--Trueshot Aura
}
--EndVariables--
						
  
--CastCheck--
function _castSpell(spellid,tar)
	if UnitCastingInfo("player") == nil
	and UnitChannelInfo("player") == nil
	and IsPlayerSpell(spellid) == true
	and cdRemains(spellid) == 0
	then
		if tar ~= nil
		and rangeCheck(spellid,tar) == nil
			then
			return false
		elseif tar ~= nil
		and rangeCheck(spellid,tar) == true
			then
			CastSpellByName(GetSpellInfo(spellid),tar)
			return true
		elseif tar == nil
			then
			CastSpellByName(GetSpellInfo(spellid))
			return true
		else
	return false
	end
end
end

function inMelee()
	if UnitAffectingCombat("player") ~= nil
	and IsSpellInRange(GetSpellInfo(78),"target") == 1
	and UnitExists("target") ~= nil
	and UnitCanAttack("player","target") ~= nil
	then return true
	end
end

function inCombat()
if UnitAffectingCombat("player") ~= nil
	then
		return true
	end
end

function cdRemains(spellid)
	if select(2,GetSpellCooldown(spellid)) + (select(1,GetSpellCooldown(spellid)) - GetTime()) > 0
		then return select(2,GetSpellCooldown(spellid)) + (select(1,GetSpellCooldown(spellid)) - GetTime())
	else return 0
	end
end

function rangeCheck(spellid,unit)
if IsSpellInRange(GetSpellInfo(spellid),unit) == 1
then
	return true
end
end

function getHp(unit)
if UnitExists(unit) ~= nil
	then
		return 100 * UnitHealth(unit) / UnitHealthMax(unit)
	end
end

function hasApBuff()
for i=1,#apBuff do
	if UnitBuffID("player",apBuff[i]) ~= nil
		then
			return true
		end
	end
end

		