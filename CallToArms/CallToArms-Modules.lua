local CallToArmsGlobal = CallToArmsGlobal

local Level = UnitLevel("player")
local LFD_MAX_SHOWN_LEVEL_DIFF = LFD_MAX_SHOWN_LEVEL_DIFF -- 15, LFD uses this to filter level range for dungeons
local ID, Name, SubType, Min, Max, Timewalking, _

local Rename = {
	[1453] = PLAYER_DIFFICULTY_TIMEWALKER, -- Random Timewalking Dungeon (Mists of Pandaria) --> Timewalking
	[1670] = LFG_TYPE_DUNGEON, -- Random Dungeon (Battle for Azeroth) --> Dungeon
	[1671] = LFG_TYPE_HEROIC_DUNGEON, -- Random Heroic (Battle for Azeroth) --> Heroic Dungeon
}

-- Find dungeons
for i = 1, GetNumRandomDungeons() do
	ID, Name, SubType, _, _, _, Min, Max, _, _, _, _, _, _, _, _, _, _, Timewalking = GetLFGRandomDungeonInfo(i)
	
	if ((Level >= (Min - LFD_MAX_SHOWN_LEVEL_DIFF)) and (Level <= (Max + LFD_MAX_SHOWN_LEVEL_DIFF))) or (Timewalking and Level >= Min) then
		CallToArmsGlobal:NewModule(ID, Rename[ID] or Name, SubType)
	end
end

-- Find raids
for i = 1, GetNumRFDungeons() do
	ID, Name, SubType, _, _, _, Min, Max = GetRFDungeonInfo(i)
	
	if (Level >= Min) and (Level <= Max) then
		CallToArmsGlobal:NewModule(ID, Name, SubType)
	end
end