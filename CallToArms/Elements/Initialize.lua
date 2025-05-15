local Name, AddOn = ...

local Version, Build, Date, TOC = GetBuildInfo()

local CTA = CreateFrame("Frame", "CallToArmsWidget", UIParent, "BackdropTemplate")
CTA:SetPoint("CENTER", UIParent)
CTA:EnableMouse(true)
CTA:SetMovable(true)
CTA:SetUserPlaced(true)

-- Assets
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
SharedMedia:Register("font", "PT Sans", "Interface\\Addons\\CallToArms\\Assets\\PTSans.ttf")

CTA.BlankTexture = "Interface\\AddOns\\CallToArms\\Assets\\HydraUIBlank.tga"
CTA.BarTexture = "Interface\\AddOns\\CallToArms\\Assets\\HydraUI4.tga"
CTA.Font = "Interface\\Addons\\CallToArms\\Assets\\PTSans.ttf"
CTA.Textures = SharedMedia:HashTable("statusbar")
CTA.Fonts = SharedMedia:HashTable("font")
CTA.SharedMedia = SharedMedia
CTA.Build = tonumber(TOC)

-- Functions
function CTA:print(...)
	print("|cffFF7C0ACTA|r:", ...)
end

function CTA:debug(...)
	if (not self.Settings.Debug) then
		return
	end

	print("|cffFF7C0ACTA [Debug]|r:", ...)
end

CTA.BlankBackdrop = {
	bgFile = CTA.BlankTexture,
}

CTA.Backdrop = {
	bgFile = CTA.BlankTexture,
	edgeFile = CTA.BlankTexture,
	edgeSize = 1,
	insets = {left = 0, right = 0, top = 0, bottom = 0},
}

function CTA:CreateTooltip()
	local Tooltip = CreateFrame("GameTooltip", "CTATooltip", UIParent, "GameTooltipTemplate")
	Tooltip:SetFrameLevel(3)
	Tooltip.NineSlice:SetAlpha(0)

	local Outside = CreateFrame("Frame", nil, Tooltip, "BackdropTemplate")
	Outside:SetPoint("TOPLEFT", Tooltip, -1, 1)
	Outside:SetPoint("BOTTOMRIGHT", Tooltip, 1, -1)
	Outside:SetBackdrop(self.Backdrop)
	Outside:SetBackdropColor(0.125, 0.133, 0.145)
	Outside:SetBackdropBorderColor(0, 0, 0)
	Outside:SetFrameLevel(1)

	self.Tooltip = Tooltip
end

CTA:CreateTooltip()

-- Events
function CTA:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

CTA:SetScript("OnEvent", CTA.OnEvent)

AddOn.CTA = CTA