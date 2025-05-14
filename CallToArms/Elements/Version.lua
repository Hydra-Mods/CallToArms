local Name, AddOn = ...
local CTA = AddOn.CTA
local L = CTA.L

local CT = ChatThrottleLib
local AddOnVersion = (C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata)("CallToArms", "Version")
local AddOnNum = tonumber(AddOnVersion)
local Me = UnitName("player")
local ChannelCD = {}

local VersionFrame = CreateFrame("Frame")

function VersionFrame:GUILD_ROSTER_UPDATE()
	if IsInGuild() then
		CT:SendAddonMessage("NORMAL", "CTA_VERSION", AddOnVersion, "GUILD")

		self:UnregisterEvent("GUILD_ROSTER_UPDATE")
	end
end

function CTA:VersionYell()
	CT:SendAddonMessage("NORMAL", "CTA_VERSION", AddOnVersion, "YELL")
end

function VersionFrame:GROUP_ROSTER_UPDATE()
	local Home = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME)
	local Instance = GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE)

	if (Home == 0 and self.SentGroup) then
		self.SentGroup = false
	elseif (Instance == 0 and self.SentInstance) then
		self.SentInstance = false
	end

	if (Instance > 0 and not self.SentInstance) then
		CT:SendAddonMessage("NORMAL", "CTA_VERSION", AddOnVersion, "INSTANCE_CHAT")
		self.SentInstance = true
	elseif (Home > 0 and not self.SentGroup) then
		CT:SendAddonMessage("NORMAL", "CTA_VERSION", AddOnVersion, IsInRaid(LE_PARTY_CATEGORY_HOME) and "RAID" or IsInGroup(LE_PARTY_CATEGORY_HOME) and "PARTY")
		self.SentGroup = true
	end
	
	CTA:UpdateGroupVisibility()
end

function VersionFrame:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if sender:find("-") then
		sender = string.match(sender, "(%S+)-%S+")
	end

	if (sender == Me or prefix ~= "CTA_VERSION") then
		return
	end

	message = tonumber(message)

	if (message >= AddOnNum) then
		ChannelCD[channel] = true
	else
		ChannelCD[channel] = false
	end

	if (AddOnNum > message) then -- We have a higher version, share it
		C_Timer.After(random(1, 8), function()
			if (not ChannelCD[channel]) then
				CT:SendAddonMessage("NORMAL", "CTA_VERSION", AddOnVersion, channel)
			end
		end)
	elseif (message > AddOnNum) then -- We're behind!
		CTA:print(L["A newer version is available! Download the latest at www.curseforge.com/wow/addons/calltoarms"])

		AddOnNum = message
		AddOnVersion = tostring(message)
	end
end

VersionFrame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

VersionFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
VersionFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
VersionFrame:RegisterEvent("CHAT_MSG_ADDON")

C_ChatInfo.RegisterAddonMessagePrefix("CTA_VERSION")