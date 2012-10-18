local ALTTimer = CreateFrame("Frame");
ALTTimer:Hide();

local ALTEventFrame = CreateFrame("Frame");
ALTEventFrame:RegisterEvent("VARIABLES_LOADED");

local CurVersion = 0.6;

-- Defaults
AutoLagToleranceDB_Defaults = {
	Version = 0.6,
	Offset = 0,
	Interval = 30,
	Threshold = 5,
	Min = nil,
	Max = nil,
};

-- Vars
local MinLatency, MaxLatency;
local LatencyInterval;
local OldLatency = -9999;

-- Initialize
ALTEventFrame:SetScript("OnEvent", function(self)
	SetCVar("reducedLagTolerance", 1);
	
	-- Get Min/Max latency values
	MinLatency = CombatPanelOptions["MaxSpellStartRecoveryOffset"].minValue or 0;
	MaxLatency = CombatPanelOptions["MaxSpellStartRecoveryOffset"].maxValue or 400;
	
	-- Defaults
	if not AutoLagToleranceDB then
		AutoLagToleranceDB = AutoLagToleranceDB_Defaults;
	end
	if not AutoLagToleranceDB.Version then
		AutoLagToleranceDB = AutoLagToleranceDB_Defaults;
	end
	if AutoLagToleranceDB.Version ~= CurVersion then
		AutoLagToleranceDB = AutoLagToleranceDB_Defaults;
	end
	AutoLagToleranceDB.Version = CurVersion;
	
	-- Start timer
	LatencyInterval = 1;
	ALTTimer:Show();
end);

local UpdatedCount = 0;

-- Timer
ALTTimer:SetScript("OnUpdate", function(self, elapsed)
	LatencyInterval = LatencyInterval - elapsed;
	if LatencyInterval <= 0 then
		-- Get Latency
		local _,_,_,Latency = GetNetStats();
		if Latency ~= OldLatency then
			
			if not Latency then Latency = 0; end
			Latency = Latency + AutoLagToleranceDB.Offset;
			
			-- Set Latency to be within Min/Max boundaries
			if AutoLagToleranceDB.Min then Latency = max(Latency, AutoLagToleranceDB.Min); end
			if AutoLagToleranceDB.Max then Latency = min(Latency, AutoLagToleranceDB.Max); end
			if Latency < MinLatency then Latency = MinLatency; end
			if Latency > MaxLatency then Latency = MaxLatency; end
			
			-- If Latency changed and greater than the change threshold, then update
			if ((Latency < OldLatency) and ((Latency + AutoLagToleranceDB.Threshold) <= OldLatency)) or ((Latency > OldLatency) and ((Latency - AutoLagToleranceDB.Threshold) >= OldLatency)) then
				SetCVar("MaxSpellStartRecoveryOffset", Latency);
				OldLatency = Latency;
			end
			
			-- Search for first real Latency update, so we can find the beginning of GetNetStats()'s 30sec update cycle
			if UpdatedCount < 2 then
				UpdatedCount = UpdatedCount + 1;
			end
		end
		
		-- Reset timer
		if UpdatedCount < 2 then
			-- Still looking for first real Latency update
			LatencyInterval = 1;
		elseif UpdatedCount < 5 then
			-- Run 3 more passes at 1sec each, so we can get 3sec ahead of the GetNetStats() update cycle
			LatencyInterval = 1;
			UpdatedCount = UpdatedCount + 1;
		else
			-- Update cycle determined, set to normal updates from now on
			LatencyInterval = AutoLagToleranceDB.Interval;
		end
	end
end);

-- Slash options
SLASH_AUTOLAG1, SLASH_AUTOLAG2 = "/autolag", "/autolagtolerance";
local function handler(msg, editbox)
	local command, val = msg:match("^(%S*)%s*(.-)$");
	
	if command == "offset" then
	-- Change Offset
		if val == "" then return end
		local NewLatencyOffset = tonumber(val);
		if not NewLatencyOffset then NewLatencyOffset = 0; end
		
		AutoLagToleranceDB.Offset = floor(NewLatencyOffset);
		
		print("New ALT offset = "..tostring(AutoLagToleranceDB.Offset));
	elseif command == "interval" then
	-- Change Interval
		if val == "" then return end
		local NewLatencyInterval = tonumber(val);	
		if not NewLatencyInterval then NewLatencyInterval = 3; end
		if NewLatencyInterval < 1 then NewLatencyInterval = 1; end
		
		AutoLagToleranceDB.Interval = NewLatencyInterval;
		
		print("New ALT interval = "..tostring(AutoLagToleranceDB.Interval));
	elseif command == "threshold" then
	-- Change Threshold
		if val == "" then return end
		local NewThreshold = tonumber(val);	
		if not NewThreshold then NewThreshold = 0; end
		if NewThreshold < 0 then NewThreshold = 0; end
		
		AutoLagToleranceDB.Threshold = floor(NewThreshold);
		
		print("New ALT threshold = "..tostring(AutoLagToleranceDB.Threshold));
	elseif command == "min" then
	-- Change Min
		local NewMin = nil;
		if val == "" then 
			NewMin = nil;
			AutoLagToleranceDB.Min = NewMin;
			print("ALT minimum is now disabled and will use the default WoW value.");
		else
			NewMin = tonumber(val);	
			if not NewMin then NewMin = 0; end
			if NewMin < MinLatency then
				NewMin = MinLatency;
				print("Note: Min can't be lower than the WoW minimum Lag Tolerance value ("..tostring(MinLatency)..").");
			end
			if NewMin > MaxLatency then 
				NewMin = MaxLatency;
				print("Note: Min can't be greater than the WoW maximum Lag Tolerance value ("..tostring(MaxLatency)..").");
			end
			if AutoLagToleranceDB.Max then
				if NewMin > AutoLagToleranceDB.Max then
					NewMin = min(MaxLatency, AutoLagToleranceDB.Max);
					print("Note: Min can't be greater than Max ("..tostring(AutoLagToleranceDB.Max)..").");
				end
			end
			
			AutoLagToleranceDB.Min = floor(NewMin);
			
			print("New ALT minimum = "..tostring(AutoLagToleranceDB.Min));
		end
	elseif command == "max" then
	-- Change Max
		local NewMax = nil;
		if val == "" then 
			NewMax = nil;
			AutoLagToleranceDB.Max = NewMax;
			print("ALT maximum is now disabled and will use the default WoW value.");
		else
			NewMax = tonumber(val);	
			if not NewMax then NewMax = 0; end
			if NewMax < MinLatency then
				NewMax = MinLatency;
				print("Note: Max can't be lower than the WoW minimum Lag Tolerance value ("..tostring(MinLatency)..").");
			end
			if NewMax > MaxLatency then 
				NewMax = MaxLatency;
				print("Note: Max can't be greater than the WoW maximum Lag Tolerance value ("..tostring(MaxLatency)..").");
			end
			if AutoLagToleranceDB.Min then
				if NewMax < AutoLagToleranceDB.Min then
					NewMax = max(MinLatency, AutoLagToleranceDB.Min);
					print("Note: Max can't be lower than Min ("..tostring(AutoLagToleranceDB.Min)..").");
				end
			end
			
			AutoLagToleranceDB.Max = floor(NewMax);
			
			print("New ALT maximum = "..tostring(AutoLagToleranceDB.Max));
		end
	elseif command == "reset" then
	-- Reset
		AutoLagToleranceDB = AutoLagToleranceDB_Defaults;
		LatencyInterval = AutoLagToleranceDB.Interval;
		print("ALT settings have been reset to their default values.");
	else
	-- Help
		local MinValue, MaxValue;
		print("-- AutoLagTolerance: Command Line help --");
		print("-")
		print("|cffffff00Syntax:|r /autolag command value");
		print("-");
		print("|cffffff00Command listing:|r");
		print("|cff50c0ffoffset|r|cffffffa0 (Current = "..tostring(AutoLagToleranceDB.Offset).."ms)|r: How much latency to add or subtract to your actual latency in milliseconds. Use to fine tune your Lag Tolerance. Example: |cff90ff90[/autolag offset -5]|r will add a negative 5ms offset to your Lag Tolerance.");
		print("|cff50c0ffinterval|r|cffffffa0 (Current = "..tostring(AutoLagToleranceDB.Interval).."s)|r: How often to update your Lag Tolerance in seconds. Min = 1. Example: |cff90ff90[/autolag interval 5]|r will update the Lag Tolerance every 5 seconds.");
		print("|cff50c0ffthreshold|r|cffffffa0 (Current = "..tostring(AutoLagToleranceDB.Threshold).."s)|r: The difference rquired between your latency and the current Lag Tolerance value in order to set a new Lag Tolerance value. Min = 0. Example: |cff90ff90[/autolag threshold 5]|r will make it so that ALT will only change your Lag Tolerance if your current latency differs from it by 5ms or more.");
		
		if AutoLagToleranceDB.Min then
			MinValue = "Current = "..tostring(AutoLagToleranceDB.Min).."ms";
		else
			MinValue = "Disabled";
		end
		print("|cff50c0ffmin|r|cffffffa0 ("..MinValue..")|r: The minimum value to set your Lag Tolerance to. Min = "..tostring(MinLatency)..". Example: |cff90ff90[/autolag min 50]|r will make it so that ALT will never set your Lag Tolerance below 50ms. Type |cff90ff90[/autolag min]|r to reset it to default.");
		
		if AutoLagToleranceDB.Max then
			MaxValue = "Current = "..tostring(AutoLagToleranceDB.Max.."ms");
		else
			MaxValue = "Disabled";
		end
		print("|cff50c0ffmax|r|cffffffa0 ("..MaxValue..")|r: The maximum value to set your Lag Tolerance to. Max = "..tostring(MaxLatency)..". Example: |cff90ff90[/autolag max 100]|r will make it so that ALT will never set your Lag Tolerance above 100ms. Type |cff90ff90[/autolag max]|r to reset it to default.");
		print("|cff50c0ffreset|r: Reset ALT settings to their default values.");
		print(" ");
		print("|cffffff00Current Lag Tolerance = |r|cff50c0ff"..tostring(GetCVar("MaxSpellStartRecoveryOffset")).."|r");
	end
end
SlashCmdList["AUTOLAG"] = handler;