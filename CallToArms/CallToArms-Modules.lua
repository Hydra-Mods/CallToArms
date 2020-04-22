local CallToArmsGlobal = CallToArmsGlobal

do -- Random Heroic (Battle for Azeroth)
	local DungeonID, DungeonName = 1671, LFG_TYPE_HEROIC_DUNGEON
	
	CallToArmsGlobal:NewModule(DungeonID, DungeonName, LFG_SUBTYPEID_HEROIC)
end

do -- Timewalking Dungeon
	-- Not sure yet if this works correctly across all locales. It *should* though?
	local ID, Name
	local Timewalking = {744, 995, 1453}
	
	for i = 1, GetNumRandomDungeons() do
		ID, Name = GetLFGRandomDungeonInfo(i)
		
		if Timewalking[ID] then
			CallToArmsGlobal:NewModule(ID, PLAYER_DIFFICULTY_TIMEWALKER, LFG_SUBTYPEID_SCENARIO)
			
			break
		end
	end
	
	--[[
		Timewalking ID's. Once I know them all I can scan for them in a better way.
		
		DungeonID, Name
		744 = Random Timewalking Dungeon (Burning Crusade) -- GetLFGRandomDungeonInfo(11)
		995 = Random Timewalking Dungeon (Wrath of the Lich King)
		1453 = Random Timewalking Dungeon (Mists of Pandaria)
	--]]
end

--/run for i = 1, GetNumRFDungeons() do local id, n = GetRFDungeonInfo(i) if n then print(i, id, " - " .. n) end end
--/run for i = 1, GetNumRandomDungeons() do local id, n = GetLFGRandomDungeonInfo(i) if n then print(i, id, " - " .. n) end end

do -- Halls of Containment
	local DungeonID, DungeonName = GetRFDungeonInfo(5)
	
	CallToArmsGlobal:NewModule(DungeonID, DungeonName, LFG_SUBTYPEID_RAID)
end

do -- Crimson Descent
	local DungeonID, DungeonName = GetRFDungeonInfo(8)
	
	CallToArmsGlobal:NewModule(DungeonID, DungeonName, LFG_SUBTYPEID_RAID)
end

do -- Heart of Corruption
	local DungeonID, DungeonName = GetRFDungeonInfo(11)
	
	CallToArmsGlobal:NewModule(DungeonID, DungeonName, LFG_SUBTYPEID_RAID)
end

do -- Defense of Dazar'alor
	local DungeonID, DungeonName = GetRFDungeonInfo(20)
	
	CallToArmsGlobal:NewModule(DungeonID, DungeonName, LFG_SUBTYPEID_RAID)
end

do -- Death's Bargain
	local DungeonID, DungeonName = GetRFDungeonInfo(28)
	
	CallToArmsGlobal:NewModule(DungeonID, DungeonName, LFG_SUBTYPEID_RAID)
end

do -- Victory or Death
	local DungeonID, DungeonName = GetRFDungeonInfo(38)
	
	CallToArmsGlobal:NewModule(DungeonID, DungeonName, LFG_SUBTYPEID_RAID)
end

do -- Crucible of Storms
	local DungeonID, DungeonName = GetRFDungeonInfo(40)
	
	CallToArmsGlobal:NewModule(DungeonID, DungeonName, LFG_SUBTYPEID_RAID)
end

do -- The Grand Reception
	local DungeonID, DungeonName = GetRFDungeonInfo(41)
	
	CallToArmsGlobal:NewModule(DungeonID, DungeonName, LFG_SUBTYPEID_RAID)
end

do -- Depths of the Devoted
	local DungeonID, DungeonName = GetRFDungeonInfo(45)
	
	CallToArmsGlobal:NewModule(DungeonID, DungeonName, LFG_SUBTYPEID_RAID)
end

do -- The Circle of Stars
	local DungeonID, DungeonName = GetRFDungeonInfo(50)
	
	CallToArmsGlobal:NewModule(DungeonID, DungeonName, LFG_SUBTYPEID_RAID)
end

do -- Vision of Destiny
	local DungeonID, DungeonName = GetRFDungeonInfo(54)
	
	CallToArmsGlobal:NewModule(DungeonID, DungeonName, LFG_SUBTYPEID_RAID)
end

do -- Halls of Devotion
	local DungeonID, DungeonName = GetRFDungeonInfo(56)
	
	CallToArmsGlobal:NewModule(DungeonID, DungeonName, LFG_SUBTYPEID_RAID)
end

do -- Gift of Flesh
	local DungeonID, DungeonName = GetRFDungeonInfo(57)
	
	CallToArmsGlobal:NewModule(DungeonID, DungeonName, LFG_SUBTYPEID_RAID)
end

do -- The Waking Dream
	local DungeonID, DungeonName = GetRFDungeonInfo(60)
	
	CallToArmsGlobal:NewModule(DungeonID, DungeonName, LFG_SUBTYPEID_RAID)
end