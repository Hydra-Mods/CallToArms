local Name, AddOn = ...
local CTA = AddOn.CTA

local Locale = GetLocale()
local DefaultFont = "PT Sans"

if (Locale == "koKR") then
	DefaultFont = "2002"
elseif (Locale == "zhCN" or Locale == "zhTW") then
	DefaultFont = "AR CrystalzcuheiGBK Demibold"
end

CTA.DefaultSettings = {
	-- Widget settings
	HeaderWidth = 160,
	HeaderHeight = 24,
	WindowFont = DefaultFont,
	LockWidget = false,
	HideInGroup = true,

	-- Role filters
	IgnoreTank = false,
	IgnoreHeal = false,
	IgnoreDamage = false,

	-- General
	FilterRoles = true,
	MinimapButton = true,

	-- Announcements
	AnnounceStart = true,
	AnnounceEnd = true,
	PlaySound = true,

	Debug = false,
}