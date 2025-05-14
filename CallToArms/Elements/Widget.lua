local Name, AddOn = ...
local CTA = AddOn.CTA
local L = CTA.L

local SharedMedia = CTA.SharedMedia
local RoleIcons = {"Interface\\Icons\\Ability_warrior_defensivestance", "Interface\\Icons\\spell_chargepositive", "Interface\\Icons\\ability_throw"}
local Class = select(2, UnitClass("player"))
local FreeQueueWidgets = {}
local QueueHighlight = "Interface\\AddOns\\CallToArms\\Assets\\RenHorizonUp.tga"

CTA.ActiveQueueBars = {}

local ClassRoleMap = {-- CanTank, CanHeal
	DEATHKNIGHT = {true, false},
	DEMONHUNTER = {true, false},
	DRUID =       {true, true},
	EVOKER =      {false, true},
	HUNTER =      {false, false},
	MAGE =        {false, false},
	MONK =        {true, true},
	PALADIN =     {true, true},
	PRIEST =      {false, true},
	ROGUE =       {false, false},
	SHAMAN =      {false, true},
	WARLOCK =     {false, false},
	WARRIOR =     {true, false},
}

function CTA:RoleButtonOnEnter()
	self.MouseOver:Show()

	local Parent = self:GetParent()

	for i = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
		local Eligable, ForTank, ForHealer, ForDamage, ItemCount = GetLFGRoleShortageRewards(Parent.ID, i)

		if (ItemCount and ItemCount > 0) then
			local Tooltip = CTA.Tooltip
			Tooltip:SetOwner(self, "ANCHOR_NONE")
			Tooltip:ClearAllPoints()
			Tooltip:SetPoint("BOTTOM", self, "TOP", 0, 5)

			Tooltip:AddLine(BONUS_REWARDS)
			Tooltip:AddLine(" ")

			for j = 1, ItemCount do
				local Name, Icon, NumRewards, _, RewardType, ID, Quality = GetLFGDungeonShortageRewardInfo(Parent.ID, i, j)

				if (RewardType == "misc") then
					Tooltip:AddLine(REWARD_ITEMS_ONLY)

					local DoneToday, Money, MoneyMod, XP, XPMod, NumRewards, SpellID = GetLFGDungeonRewards(Parent.ID)

					if (XP > 0) then
						Tooltip:AddLine(format(GAIN_EXPERIENCE, XP))
					end

					if (Money > 0) then
						SetTooltipMoney(Tooltip, Money, nil)
					end

					Tooltip:Show()
				elseif (RewardType == "reward") then
					Tooltip:SetLFGDungeonReward(Parent.ID, j)
					Tooltip:Show()
				elseif (RewardType == "shortage") then
					Tooltip:SetLFGDungeonShortageReward(Parent.ID, j, i)
					Tooltip:Show()
				elseif (RewardType == "item") then
					local Link = GetLFGDungeonShortageRewardLink(Parent.ID, i, j)

					if Link then
						if (NumRewards > 1) then
							Tooltip:AddLine(format("%s %s", NumRewards, Link))
						else
							Tooltip:AddLine(Link)
						end

						Tooltip:Show()
					end
				elseif (RewardType == "currency") then
					local CurrencyNum = select(3, CurrencyContainerUtil.GetCurrencyContainerInfo(ID, NumRewards, Name, Icon, Quality))
					local Link = C_CurrencyInfo.GetCurrencyLink(ID, CurrencyNum)
					local CurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(ID)
					local Hex = ITEM_QUALITY_COLORS[CurrencyInfo.quality].hex or "ffffff"

					if CurrencyInfo then
						Tooltip:AddLine(format("%s %s%s|r", NumRewards, Hex, CurrencyInfo.name), 1, 1, 1)
						Tooltip:Show()
					end
				end
			end
		end
	end
end

function CTA:RoleButtonOnLeave()
	self.MouseOver:Hide()

	CTA.Tooltip:Hide()
end

local IsQueued = function(id)
	for i, v in ipairs(LFGQueuedForList) do
		if v[id] then
			return true
		end
	end

	return false
end

function CTA:UpdateQueueIndicators()
	for i, Header in ipairs(self.ActiveQueueBars) do
		if IsQueued(Header.ID) then
			Header.QueuedOverlay:Show()
		else
			Header.QueuedOverlay:Hide()
		end
	end
end

function CTA:QueueForDungeon()
	local Parent = self:GetParent()

	ClearAllLFGDungeons(Parent.SubType)

	local Eligable, ForTank, ForHealer, ForDamage = GetLFGRoleShortageRewards(Parent.ID, LFG_ROLE_SHORTAGE_RARE)
	local Leader = GetLFGRoles()

	-- Check if we can perform this role. A generic error message would come up anyways, but we'll add our own.
	if (self.RoleID == 1) then
		if (ForTank and not ClassRoleMap[Class][self.RoleID]) then
			CTA:print(YOUR_CLASS_MAY_NOT_PERFORM_ROLE)

			return
		end
	elseif (self.RoleID == 2) then
		if (ForHealer and not ClassRoleMap[Class][self.RoleID]) then
			CTA:print(YOUR_CLASS_MAY_NOT_PERFORM_ROLE)

			return
		end
	end

	SetLFGDungeon(Parent.SubType, Parent.ID)
	SetLFGRoles(Leader, self.RoleID == 1, self.RoleID == 2, self.RoleID == 3)

	if (Parent.SubType == LE_LFG_CATEGORY_LFD) then
		LFDFrame_DisplayDungeonByID(Parent.ID)
		LFDQueueFrame_UpdateRoleButtons()
	elseif (Parent.SubType == LE_LFG_CATEGORY_RF) then
		LFG_UpdateQueuedList()
		LFG_UpdateAllRoleCheckboxes()
	end

	JoinLFG(Parent.SubType)

	CTA:UpdateQueueIndicators()
end

function CTA:AddQueueBar(name)
	local Header = CreateFrame("Frame", nil, self.Widget, "BackdropTemplate")
	Header:SetSize(self.Settings.HeaderWidth, self.Settings.HeaderHeight)
	Header:SetPoint("CENTER", UIParent)
	Header:SetBackdrop(self.Backdrop)
	Header:SetBackdropColor(0.125, 0.133, 0.145)
	Header:SetBackdropBorderColor(0, 0, 0)
	Header:Hide()

	Header:SetScript("OnEnter", function(self)
		CTA.Tooltip:SetOwner(self, "ANCHOR_NONE")
		CTA.Tooltip:SetPoint("BOTTOM", Header, "TOP", 0, 4)
		CTA.Tooltip:ClearLines()
		CTA.Tooltip:AddLine(name)

		if IsQueued(Header.ID) then
			CTA.Tooltip:AddLine(" ")
			CTA.Tooltip:AddLine(L["|cff00ccffYou are currently queued for this dungeon|r"])
		end

		CTA.Tooltip:Show()
	end)

	Header:SetScript("OnLeave", function(self)
		CTA.Tooltip:Hide()
	end)

	local QueuedOverlay = Header:CreateTexture(nil, "ARTWORK")
	QueuedOverlay:SetPoint("TOPLEFT", Header, 1, -1)
	QueuedOverlay:SetPoint("BOTTOMRIGHT", Header, -1, 1)
	QueuedOverlay:SetTexture(QueueHighlight)
	--QueuedOverlay:SetTexture(self.BarTexture)
	QueuedOverlay:SetVertexColor(0.7686, 0.7686, 0.3019, 0.25)
	QueuedOverlay:Hide()

	local Label = Header:CreateFontString(nil, "OVERLAY")
	Label:SetPoint("LEFT", Header, 5, -0.5)
	Label:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12)
	Label:SetJustifyH("LEFT")
	Label:SetText(string.format("|cffFFC44D%s|r", name))
	Label:SetSize(self.Settings.HeaderWidth - 12, self.Settings.HeaderHeight)
	Label:SetShadowColor(0.01, 0.01, 0.01)
	Label:SetShadowOffset(0, -1)

	Header.QueuedOverlay = QueuedOverlay
	Header.Label = Label
	Header.RoleButtons = {}

	for i = 1, 3 do
		local Role = CreateFrame("Frame", nil, Header)
		Role:SetSize(self.Settings.HeaderHeight - 2, self.Settings.HeaderHeight - 2)
		Role:SetScript("OnEnter", self.RoleButtonOnEnter)
		Role:SetScript("OnLeave", self.RoleButtonOnLeave)
		Role:SetScript("OnMouseUp", self.QueueForDungeon)
		Role:Hide()

		local IconBG = Role:CreateTexture(nil, "BACKGROUND")
		IconBG:SetPoint("TOPLEFT", Role, -1, 1)
		IconBG:SetPoint("BOTTOMRIGHT", Role, 1, -1)
		IconBG:SetTexture(self.BlankTexture)
		IconBG:SetVertexColor(0, 0, 0)

		local Icon = Role:CreateTexture(nil, "ARTWORK")
		Icon:SetPoint("TOPLEFT", Role, 0, 0)
		Icon:SetPoint("BOTTOMRIGHT", Role, 0, 0)
		Icon:SetTexture(RoleIcons[i])
		Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

		local MouseOver = Role:CreateTexture(nil, "OVERLAY")
		MouseOver:SetPoint("TOPLEFT", Role, 0, 0)
		MouseOver:SetPoint("BOTTOMRIGHT", Role, 0, 0)
		MouseOver:SetTexture(self.BlankTexture)
		MouseOver:SetVertexColor(0.8, 0.8, 0.8)
		MouseOver:SetAlpha(0.3)
		MouseOver:Hide()

		Role.RoleID = i
		Role.IconBG = IconBG
		Role.Icon = Icon
		Role.MouseOver = MouseOver

		if (i == 1) then
			Role:SetPoint("LEFT", Header, "RIGHT", 0, 0)
		else
			Role:SetPoint("LEFT", Header.RoleButtons[i-1], "RIGHT", 1, 0)
		end

		Header.RoleButtons[i] = Role
	end

	table.insert(self.ActiveQueueBars, Header)

	return Header
end

function CTA:SortQueueHeaders()
	local Header
	local Previous

	for i = 1, #self.ActiveQueueBars do
		Header = self.ActiveQueueBars[i]

		if Header:IsShown() then
			Header:ClearAllPoints()

			if (not Previous) then
				Header:SetPoint("TOPLEFT", self.Widget, "BOTTOMLEFT", 0, -3)
			else
				Header:SetPoint("TOPLEFT", Previous, "BOTTOMLEFT", 0, -3)
			end

			Previous = Header

			self:SortQueueRoles(Header)
		end
	end
end

function CTA:SortClassicQueueRoles(header)
	local Previous

	for i = 1, 3 do
		Role = header.RoleButtons[i]

		if Role:IsShown() then
			Role:ClearAllPoints()

			if (not Previous) then
				Role:SetPoint("LEFT", header.RoleSelection, 1, 0)
			else
				Role:SetPoint("LEFT", Previous, "RIGHT", 1, 0)
			end

			Previous = Role
		end
	end

	Previous = nil
end

function CTA:SortQueueRoles(header)
	local Previous

	for i = 1, 3 do
		Role = header.RoleButtons[i]

		if Role:IsShown() then
			Role:ClearAllPoints()

			if (not Previous) then
				Role:SetPoint("LEFT", header, "RIGHT", 0, 0)
			else
				Role:SetPoint("LEFT", Previous, "RIGHT", 1, 0)
			end

			Previous = Role
		end
	end

	Previous = nil
end

function CTA:CloseButtonOnEnter()
	self.Texture:SetVertexColor(0.9, 0.1, 0.1)
end

function CTA:CloseButtonOnLeave()
	self.Texture:SetVertexColor(1, 1, 1)
end

function CTA:CloseButtonMouseUp()
	CTA:ToggleWidget()
end

function CTA:CreateWidget()
	-- Header
	self:SetSize(self.Settings.HeaderWidth, self.Settings.HeaderHeight)
	self:SetBackdrop(self.Backdrop)
	self:SetBackdropColor(0.125, 0.133, 0.145)
	self:SetBackdropBorderColor(0, 0, 0)
	self:RegisterForDrag("LeftButton")
	self:SetClampedToScreen(true)

	local Label = self:CreateFontString(nil, "OVERLAY")
	Label:SetPoint("LEFT", self, 6, -0.5)
	Label:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12)
	Label:SetText(string.format("|cffFFC44D%s|r", L["Call to Arms"]))
	Label:SetShadowColor(0.01, 0.01, 0.01)
	Label:SetShadowOffset(0, -1)

	local Close = CreateFrame("Frame", nil, self)
	Close:SetPoint("RIGHT", self, 0, 0)
	Close:SetSize(self.Settings.HeaderHeight, self.Settings.HeaderHeight)
	Close:SetScript("OnEnter", self.CloseButtonOnEnter)
	Close:SetScript("OnLeave", self.CloseButtonOnLeave)
	Close:SetScript("OnMouseUp", self.CloseButtonMouseUp)

	local CloseTexture = Close:CreateTexture(nil, "OVERLAY")
	CloseTexture:SetPoint("CENTER", Close, 0, 0)
	CloseTexture:SetSize(16, 16)
	CloseTexture:SetTexture("Interface\\AddOns\\CallToArms\\Assets\\HydraUIClose.tga")

	if (not self.Settings.LockWidget) then
		self:SetScript("OnDragStart", self.StartMoving)
		self:SetScript("OnDragStop", self.StopMovingOrSizing)
	end

	self.Label = Label
	self.Close = Close
	Close.Texture = CloseTexture

	self.Widget = self
end

function CTA:ToggleWidget()
	if (not self.Widget) then
		self:CreateWidget()

		return
	end

	if self.Widget:IsShown() then
		self.Widget:Hide()
	else
		self.Widget:Show()
	end
end

function CTA:UpdateGroupVisibility()
	if (not self.Widget) then
		return
	end

	if self.Settings.HideInGroup and (IsInGroup() or IsInRaid()) then
		self.Widget:Hide()
	elseif not self.Widget:IsShown() then
		self.Widget:Show()
	end
end