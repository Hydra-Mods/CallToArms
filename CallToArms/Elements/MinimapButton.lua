local Name, AddOn = ...
local CTA = AddOn.CTA
local L = CTA.L

local Text = L["Call to Arms"]
local LibDBIcon = LibStub("LibDBIcon-1.0")
local MinimapButton = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(Text, {label = Text, type = "data source", icon = 348524, text = Text})

if (LibDBIcon and not LibDBIcon:IsRegistered(Text)) then
	LibDBIcon:Register(Text, MinimapButton)
end

MinimapButton.OnClick = function(self, button)
	if (button == "LeftButton") then
		CTA:ToggleWidget()
	else
		if (not CTA.GUI) then
			CTA:CreateGUI()

			return
		end

		if CTA.GUI:IsShown() then
			CTA.GUI:Hide()
		else
			CTA.GUI:Show()
		end
	end
end

MinimapButton.OnEnter = function(self)
	local Tooltip = CTA.Tooltip

	Tooltip:ClearLines()
	Tooltip:SetOwner(self, "ANCHOR_NONE")
	Tooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT")
	Tooltip:AddLine(Text)
	Tooltip:AddLine(" ")
	Tooltip:AddLine(L["|cff00ccffLeft-Click:|r Toggle Widget"])
	Tooltip:AddLine(L["|cff00ccffRight-Click:|r Open Settings"])
	Tooltip:Show()
end

MinimapButton.OnLeave = function()
	CTA.Tooltip:Hide()
end

--[[if self.Settings.MinimapButton then
	LibDBIcon:Show(Text)
else
	LibDBIcon:Hide(Text)
end]]