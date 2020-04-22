local CallToArmsGlobal = CallToArmsGlobal

local Level = UnitLevel("player")
local LFD_MAX_SHOWN_LEVEL_DIFF = LFD_MAX_SHOWN_LEVEL_DIFF -- LFD uses this to filter level range for dungeons

-- Find dungeons
for i = 1, GetNumRandomDungeons() do
	ID, Name, SubType, _, _, _, Min, Max = GetLFGRandomDungeonInfo(i)
	
	if ((Level >= (Min - LFD_MAX_SHOWN_LEVEL_DIFF)) and (Level <= (Max + LFD_MAX_SHOWN_LEVEL_DIFF))) then
		CallToArmsGlobal:NewModule(ID, Name, SubType)
	end
end

-- Find raids
for i = 1, GetNumRFDungeons() do
	ID, Name, SubType, _, _, _, Min, Max = GetRFDungeonInfo(i)
	
	if (Level >= Min) and (Level <= Max) then
		CallToArmsGlobal:NewModule(ID, Name, SubType)
	end
end