local CallToArmsGlobal = CallToArmsGlobal

local Level = UnitLevel("player")

-- Find dungeons
for i = 1, GetNumRandomDungeons() do
	ID, Name, SubType, _, _, _, Min, Max = GetLFGRandomDungeonInfo(i)
	print(Name, SubType)
	if (Level >= Min and Level <= Max) then
		CallToArmsGlobal:NewModule(ID, Name, SubType)
	end
end

-- Find raids
for i = 1, GetNumRFDungeons() do
	ID, Name, SubType, _, _, _, Min, Max = GetRFDungeonInfo(i)
	
	if (Level >= Min and Level <= Max) then
		CallToArmsGlobal:NewModule(ID, Name, SubType)
	end
end