local Options = {}

Options.AnnounceStart = true -- Announce when a bonus queue begins
Options.AnnounceEndings = false -- Announce when a bonus queue ends
Options.UpdateInterval = 45 -- Number of seconds between updates
Options.WindowAlpha = 1 -- The transparency of the window
Options.FilterRole = false -- Filter out roles we can't perform
Options.HideInGroup = true -- Disable scanning in groups & dungeons, and hide the frame
Options.MinimizeInGroup = false -- Automatically minimize while in groups
Options.PlaySound = true -- Play a sound when a new queue appears
Options.Minimized = false

local UpdateInt = 45
local CombatTime = 0
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local RequestLFDPlayerLockInfo = RequestLFDPlayerLockInfo
local GetLFGRoleShortageRewards = GetLFGRoleShortageRewards
local LFG_ROLE_NUM_SHORTAGE_TYPES = LFG_ROLE_NUM_SHORTAGE_TYPES
local LFG_ROLE_SHORTAGE_RARE = LFG_ROLE_SHORTAGE_RARE
local LE_LFG_CATEGORY_LFD = LE_LFG_CATEGORY_LFD
local LE_LFG_CATEGORY_LFR = LE_LFG_CATEGORY_LFR
local LE_LFG_CATEGORY_RF = LE_LFG_CATEGORY_RF
local ClearAllLFGDungeons = ClearAllLFGDungeons
local SetLFGDungeon = SetLFGDungeon
local GetLFGRoles = GetLFGRoles
local SetLFGRoles = SetLFGRoles
local JoinLFG = JoinLFG
local format = format
local print = print
local pairs = pairs

local RolesName = {TANK, HEALER, DAMAGER}
local RoleIcons = {"Interface\\Icons\\Ability_warrior_defensivestance", "Interface\\Icons\\spell_chargepositive", "Interface\\Icons\\ability_throw"}

local BATTLEGROUND_HOLIDAY = "Call to Arms"

local Class = select(2, UnitClass("player"))

local RoleMapByClass = {-- CanTank, CanHeal
	["DEATHKNIGHT"] = {true, false},
	["DEMONHUNTER"] = {true, false},
	["DRUID"] =       {true, true},
	["HUNTER"] =      {false, false},
	["MAGE"] =        {false, false},
	["MONK"] =        {true, true},
	["PALADIN"] =     {true, true},
	["PRIEST"] =      {false, true},
	["ROGUE"] =       {false, false},
	["SHAMAN"] =      {false, true},
	["WARLOCK"] =     {false, false},
	["WARRIOR"] =     {true, false},
}

local BlankTex = "Interface\\AddOns\\CallToArms\\Blank.tga"
local BarTex = "Interface\\AddOns\\CallToArms\\vUI4.tga"
local Font = "Interface\\Addons\\CallToArms\\PTSans.ttf"

local StartMessage = "|cffeaeaeaCall To Arms: %s %s bonus is active!|r"
local EndedMessage = "|cffeaeaeaCall To Arms: %s %s bonus has ended.|r"
local InvalidRole = "|cffeaeaeaCall To Arms: Your class cannot perform the role of %s.|r"

local Outline = {
	bgFile = BlankTex,
	edgeFile = BlankTex,
	edgeSize = 1,
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

local CallToArms = CreateFrame("Frame", "CallToArmsGlobal", UIParent)
CallToArms:SetSize(130, 18)
CallToArms:SetPoint("LEFT", UIParent, 8, 0)
CallToArms:SetMovable(true)
CallToArms:EnableMouse(true)
CallToArms:SetUserPlaced(true)
CallToArms:RegisterForDrag("LeftButton")
CallToArms:SetScript("OnDragStart", CallToArms.StartMoving)
CallToArms:SetScript("OnDragStop", CallToArms.StopMovingOrSizing)
CallToArms.Ready = false
CallToArms.Ela = 0
CallToArms.NumActive = 0
CallToArms.NumHeaders = 0
CallToArms.Headers = {}
CallToArms.HeadersByIndex = {}

CallToArms.BG = CallToArms:CreateTexture(nil, "BORDER")
CallToArms.BG:SetPoint("TOPLEFT", CallToArms, -1, 1)
CallToArms.BG:SetPoint("BOTTOMRIGHT", CallToArms, 1, -1)
CallToArms.BG:SetTexture(BlankTex)
CallToArms.BG:SetVertexColor(0, 0, 0)

CallToArms.Texture = CallToArms:CreateTexture(nil, "ARTWORK")
CallToArms.Texture:SetPoint("TOPLEFT", CallToArms, 0, 0)
CallToArms.Texture:SetPoint("BOTTOMRIGHT", CallToArms, 0, 0)
CallToArms.Texture:SetTexture(BarTex)
CallToArms.Texture:SetVertexColor(0.2, 0.2, 0.2)

CallToArms.Text = CallToArms:CreateFontString(nil, "OVERLAY")
CallToArms.Text:SetPoint("LEFT", CallToArms, 4, -0.5)
CallToArms.Text:SetFont(Font, 12)
CallToArms.Text:SetJustifyH("LEFT")
CallToArms.Text:SetShadowColor(0, 0, 0)
CallToArms.Text:SetShadowOffset(1, -1)
CallToArms.Text:SetText(BATTLEGROUND_HOLIDAY)
CallToArms.Text:SetTextColor(0.92, 0.92, 0.92)

CallToArms.CloseButton = CreateFrame("Frame", nil, CallToArms)
CallToArms.CloseButton:SetPoint("TOPRIGHT", CallToArms, 0, 0)
CallToArms.CloseButton:SetSize(18, 18)
CallToArms.CloseButton:SetScript("OnEnter", function(self) self.Texture:SetVertexColor(1, 0, 0) end)
CallToArms.CloseButton:SetScript("OnLeave", function(self) self.Texture:SetVertexColor(0.92, 0.92, 0.92) end)
CallToArms.CloseButton:SetScript("OnMouseUp", function() CallToArms:Hide() end)

CallToArms.CloseButton.Texture = CallToArms.CloseButton:CreateTexture(nil, "OVERLAY")
CallToArms.CloseButton.Texture:SetPoint("CENTER", CallToArms.CloseButton, 0, 0)
CallToArms.CloseButton.Texture:SetTexture("Interface\\AddOns\\CallToArms\\vUIClose.tga")
CallToArms.CloseButton.Texture:SetVertexColor(0.92, 0.92, 0.92)

CallToArms.ToggleButton = CreateFrame("Frame", nil, CallToArms)
CallToArms.ToggleButton:SetPoint("RIGHT", CallToArms.CloseButton, "LEFT", 0, -0.5)
CallToArms.ToggleButton:SetSize(18, 18)
CallToArms.ToggleButton:SetScript("OnEnter", function(self) self.Texture:SetVertexColor(1, 0, 0) end)
CallToArms.ToggleButton:SetScript("OnLeave", function(self) self.Texture:SetVertexColor(0.92, 0.92, 0.92) end)
CallToArms.ToggleButton:SetScript("OnMouseUp", function() CallToArms:Toggle() end)

CallToArms.ToggleButton.Texture = CallToArms.ToggleButton:CreateTexture(nil, "OVERLAY")
CallToArms.ToggleButton.Texture:SetPoint("CENTER", CallToArms.ToggleButton, 0, -0.5)
CallToArms.ToggleButton.Texture:SetTexture("Interface\\AddOns\\CallToArms\\vUIArrowUp.tga")
CallToArms.ToggleButton.Texture:SetVertexColor(0.92, 0.92, 0.92)

CallToArms.Backdrop = CreateFrame("Frame", nil, CallToArms)
CallToArms.Backdrop:SetPoint("TOPLEFT", CallToArms, -4, 4)
CallToArms.Backdrop:SetPoint("BOTTOMRIGHT", CallToArms, 4, -4)
CallToArms.Backdrop:SetBackdrop(Outline)
CallToArms.Backdrop:SetBackdropColor(0.2, 0.2, 0.2)
CallToArms.Backdrop:SetBackdropBorderColor(0, 0, 0)
CallToArms.Backdrop:SetFrameStrata("LOW")

CallToArms.VisualParent = CreateFrame("Frame", nil, CallToArms)

CallToArms.SoundThrottle = CreateFrame("Frame")
CallToArms.SoundThrottle.Ela = 0
CallToArms.SoundThrottle.CanPlaySound = true

local SoundThrottleOnUpdate = function(self, ela)
	self.Ela = self.Ela + ela
	
	if (self.Ela > 3) then
		self:SetScript("OnUpdate", nil)
		self.CanPlaySound = true
		self.Ela = 0
	end
end

function CallToArms:PlaySound()
	if (not Options.PlaySound) or (not self.SoundThrottle.CanPlaySound) then
		return
	end
	
	PlaySound(SOUNDKIT.MAP_PING, "Master")
	
	self.SoundThrottle.CanPlaySound = false
	self.SoundThrottle:SetScript("OnUpdate", SoundThrottleOnUpdate)
end

local IsQueued = function(id)
	for i = 1, #LFGQueuedForList do
		for k, v in pairs(LFGQueuedForList[i]) do
			if ((k == id) and v) then
				return true
			end
		end
	end
	
	return false
end

local UpdateQueueStatus = function(id)
	local Header
	
	for k, v in pairs(CallToArms.Headers) do
		if (v.DungeonID == id) then
			Header = v
			
			break
		end
	end
	
	if (not Header) then
		return
	end
	
	if IsQueued(id) then
		Header.IsQueued:Show()
	else
		Header.IsQueued:Hide()
	end
end

local UpdateAllQueues = function()
	for k, v in pairs(CallToArms.Headers) do
		UpdateQueueStatus(v.DungeonID)
	end
end

local OnUpdate = function(self, ela)
	self.Ela = self.Ela + ela
	
	if (self.Ela > UpdateInt) then
		RequestLFDPlayerLockInfo()
		self.Ela = 0
	end
end

function CallToArms:PLAYER_REGEN_ENABLED()
	self.Ela = self.Ela + (GetTime() - CombatTime)
	
	self:SetScript("OnUpdate", OnUpdate)
end

function CallToArms:PLAYER_REGEN_DISABLED()
	self:SetScript("OnUpdate", nil)
	
	CombatTime = GetTime()
end

function CallToArms:PLAYER_ENTERING_WORLD()
	if (not self.FirstRun) then
		self.FirstRun = true
		
		if (UnitLevel("player") ~= MAX_PLAYER_LEVEL) then -- We're only interested in max level information here.
			self:UnregisterAllEvents()
			self:Hide()
			
			return
		end
		
		self:UpdateAlpha(Options.WindowAlpha)
	end
	
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function CallToArms:LFG_UPDATE_RANDOM_INFO()
	if (not self.Ready) then
		return
	end
	
	UpdateAllQueues()
	
	self.NumActive = 0
	
	for k, v in pairs(self.Headers) do
		v:Update()
	end
	
	if (Options.Minimized and self.NumActive > 0) then
		self.Text:SetText(BATTLEGROUND_HOLIDAY .. " (" .. self.NumActive .. ")")
	else
		self.Text:SetText(BATTLEGROUND_HOLIDAY)
	end
	
	if (not self.MinimizedCheck) then
		if Options.Minimized then
			self:Minimize()
		end
		
		self.MinimizedCheck = true
	end	
	
	if (not self:GetScript("OnUpdate") and (not InCombatLockdown())) then
		self:SetScript("OnUpdate", OnUpdate)
	end
end

function CallToArms:VARIABLES_LOADED()
	if (not CallToArms) then
		CallToArms = {}
	end

	for k, v in pairs(CallToArms) do
		Options[k] = v
	end
	
	self.Ready = true
	
	if Options.MinimizeInGroup then
		self:RegisterEvent("GROUP_ROSTER_UPDATE")
	end
	
	for i = 1, self.NumHeaders do
		if (CallToArms["Enable"..self.HeadersByIndex[i].DungeonName] == true) then
			self.HeadersByIndex[i]:Enable()
		--else
		--	self.HeadersByIndex[i]:Disable()
		end
	end
end

function CallToArms:GROUP_ROSTER_UPDATE()
	if self.Minimized then
		return
	end
	
	if (IsInGroup() or IsInRaid()) then
		self:Minimize()
	end
end

function CallToArms:LFG_UPDATE()
	UpdateAllQueues()
end

function CallToArms:SortHeaders()
	local LastHeader = self
	
	for k, v in pairs(self.Headers) do
		if (not v.IsDisabled and v:IsVisible()) then
			v:ClearAllPoints()
			
			if (LastHeader == self) then
				v:SetPoint("TOPLEFT", LastHeader, "BOTTOMLEFT", -1, -3)
			else
				v:SetPoint("TOPLEFT", LastHeader.LastShown, "BOTTOMLEFT", 0, -2)
			end
			
			LastHeader = v
		end
	end
	
	if Options.Minimized then
		self.Backdrop:SetPoint("BOTTOMRIGHT", self, 4, -4)
	else
		if (LastHeader == self) then
			CallToArms.Backdrop:SetPoint("BOTTOMRIGHT", self, 4, -4)
		else
			CallToArms.Backdrop:SetPoint("BOTTOMRIGHT", LastHeader.LastShown, 3, -3)
		end
	end
end

function CallToArms:Minimize()
	self.VisualParent:SetAlpha(0)
	
	Options.Minimized = true
	CallToArms.Minimized = true
	
	self.ToggleButton.Texture:SetTexture("Interface\\AddOns\\CallToArms\\vUIArrowDown.tga")
	
	self.NumActive = 0
	
	for k, v in pairs(self.Headers) do
		for i = 1, 3 do
			v[i]:EnableMouse(false)
		end
		
		v:Update()
	end
	
	self:SortHeaders()
	
	if (self.NumActive > 0) then
		self.Text:SetText(BATTLEGROUND_HOLIDAY .. " (" .. self.NumActive .. ")")
	else
		self.Text:SetText(BATTLEGROUND_HOLIDAY)
	end
end

function CallToArms:Maximize()
	self.VisualParent:SetAlpha(1)
	
	Options.Minimized = false
	CallToArms.Minimized = false
	
	self.ToggleButton.Texture:SetTexture("Interface\\AddOns\\CallToArms\\vUIArrowUp.tga")
	
	self.NumActive = 0
	
	for k, v in pairs(self.Headers) do
		for i = 1, 3 do
			v[i]:EnableMouse(true)
		end
		
		v:Update()
	end
	
	self:SortHeaders()
	
	self.Text:SetText(BATTLEGROUND_HOLIDAY)
end

function CallToArms:Toggle()
	if (self.VisualParent:GetAlpha() == 1) then
		self:Minimize()
	else
		self:Maximize()
	end
end

function CallToArms:UpdateAlpha(value)
	for k, v in pairs(self.Headers) do
		v.Texture:SetAlpha(value)
		
		for i = 1, 3 do
			v[i].Texture:SetAlpha(value)
		end
	end
	
	self.Backdrop:SetBackdropColor(0.2, 0.2, 0.2, value)
end

local OnEvent = function(self, event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

CallToArms:RegisterEvent("PLAYER_ENTERING_WORLD")
CallToArms:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
CallToArms:RegisterEvent("PLAYER_REGEN_ENABLED")
CallToArms:RegisterEvent("PLAYER_REGEN_DISABLED")
CallToArms:RegisterEvent("VARIABLES_LOADED")
CallToArms:RegisterEvent("CHAT_MSG_ADDON")
CallToArms:RegisterEvent("LFG_UPDATE")
CallToArms:SetScript("OnEvent", OnEvent)

local Update = function(self)
	if self.Disabled then
		return
	end
	
	self.TankActive = false
	self.HealerActive = false
	self.DamageActive = false
	
	for i = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
		local Eligable, ForTank, ForHealer, ForDamage, ItemCount = GetLFGRoleShortageRewards(self.DungeonID, i)
		
		if (ItemCount and ItemCount > 0) then
			if ForTank then
				self.TankActive = true
				CallToArms.NumActive = CallToArms.NumActive + 1
			end
			
			if ForHealer then
				self.HealerActive = true
				CallToArms.NumActive = CallToArms.NumActive + 1
			end
			
			if ForDamage then
				self.DamageActive = true
				CallToArms.NumActive = CallToArms.NumActive + 1
			end
		end
	end
	
	if self.TankActive then
		if self.AnnounceTank then
			if (Options.FilterRole and not RoleMapByClass[Class][1]) then
				return
			end
			
			self[1]:Show()
			self:Sort()
			CallToArms:PlaySound()
			
			if Options.AnnounceStart then
				print(format(StartMessage, self.DungeonName, RolesName[1]))
			end
			
			self.AnnounceTank = false
		end
	else
		if (not self.AnnounceTank) then
			self[1]:Hide()
			self:Sort()
			
			if Options.AnnounceEndings then
				if Options.AnnounceStart then
					print(format(EndedMessage, self.DungeonName, RolesName[1]))
				end
			end
			
			self.AnnounceTank = true
		end
	end
	
	if self.HealerActive then
		if self.AnnounceHealer then
			if (Options.FilterRole and not RoleMapByClass[Class][2]) then
				return
			end
			
			self[2]:Show()
			self:Sort()
			CallToArms:PlaySound()
			
			if Options.AnnounceStart then
				print(format(StartMessage, self.DungeonName, RolesName[2]))
			end
			
			self.AnnounceHealer = false
		end
	else
		if (not self.AnnounceHealer) then
			self[2]:Hide()
			self:Sort()
			
			if Options.AnnounceEndings then
				if Options.AnnounceStart then
					print(format(EndedMessage, self.DungeonName, RolesName[2]))
				end
			end
			
			self.AnnounceHealer = true
		end	
	end
	
	if self.DamageActive then
		if self.AnnounceDPS then
			self[3]:Show()
			self:Sort()
			CallToArms:PlaySound()
			
			if Options.AnnounceStart then
				print(format(StartMessage, self.DungeonName, RolesName[3]))
			end
			
			self.AnnounceDPS = false
		end
	else
		if (not self.AnnounceDPS) then
			self[3]:Hide()
			self:Sort()
			
			if Options.AnnounceEndings then
				if Options.AnnounceStart then
					print(format(EndedMessage, self.DungeonName, RolesName[3]))
				end
			end
			
			self.AnnounceDPS = true
		end
	end
end

local FilterUpdate = function(self)
	self.TankActive = false
	self.HealerActive = false
	self.DamageActive = false
	
	for i = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
		local Eligable, ForTank, ForHealer, ForDamage, ItemCount = GetLFGRoleShortageRewards(self.DungeonID, i)
		
		if (ItemCount and ItemCount > 0) then
			if ForTank then
				self.TankActive = true
			end
			
			if ForHealer then
				self.HealerActive = true
			end
		end
	end
	
	if self.TankActive then
		if (Options.FilterRole and not RoleMapByClass[Class][1]) then
			self[1]:Hide()
			self:Sort()
			self.AnnounceTank = true
		end
	end
	
	if self.HealerActive then
		if (Options.FilterRole and not RoleMapByClass[Class][2]) then
			self[2]:Hide()
			self:Sort()
			self.AnnounceHealer = true
		end
	end
end

local OnShow = function(self)
	self.Flash:SetSize(130, 18)

	self.FlashAnim:Play()
end

local OnClick = function(self, button)
	ClearAllLFGDungeons(LE_LFG_CATEGORY_LFD)
	ClearAllLFGDungeons(LE_LFG_CATEGORY_LFR)
	ClearAllLFGDungeons(LE_LFG_CATEGORY_RF)
	
	local Eligable, ForTank, ForHealer, ForDamage = GetLFGRoleShortageRewards(self.DungeonID, LFG_ROLE_SHORTAGE_RARE)
	local Leader = GetLFGRoles()
	
	-- Check if we can perform this role. A generic error message would come up anyways, but we'll make our own.
	if (self.RoleID == 1) then
		if (ForTank and not RoleMapByClass[Class][self.RoleID]) then
			print(format(InvalidRole, TANK))
			
			return
		end
	elseif (self.RoleID == 2) then
		if (ForHealer and not RoleMapByClass[Class][self.RoleID]) then
			print(format(InvalidRole, HEALER))
			
			return
		end
	end
	
	UpdateQueueStatus(self.DungeonID)
	
	SetLFGRoles(Leader, ForTank, ForHealer, ForDamage)
	SetLFGDungeon(self.SubTypeID, self.DungeonID)
	JoinLFG(self.SubTypeID)
end

local OnEnter = function(self)
	self.MouseOver:SetAlpha(1)
end

local OnLeave = function(self)
	self.MouseOver:SetAlpha(0)
end

function CallToArms:NewModule(id, name, subtypeid)
	local Header = CreateFrame("Frame", nil, self.VisualParent)
	Header:SetSize(132, 20)
	Header:SetPoint("LEFT", UIParent, 8, 0)
	Header.Ela = 0
	Header:Hide()
	Header.DungeonID = id
	Header.DungeonName = name
	Header.Update = Update
	Header.FilterUpdate = FilterUpdate
	Header.Disabled = false
	
	Header:SetBackdrop(Outline)
	Header:SetBackdropColor(0, 0, 0, 0)
	Header:SetBackdropBorderColor(0, 0, 0)
	
	Header.Texture = Header:CreateTexture(nil, "ARTWORK")
	Header.Texture:SetPoint("TOPLEFT", Header, 1, -1)
	Header.Texture:SetPoint("BOTTOMRIGHT", Header, -1, 1)
	Header.Texture:SetTexture(BarTex)
	Header.Texture:SetVertexColor(0.2, 0.2, 0.2)
	
	Header.Text = Header:CreateFontString(nil, "OVERLAY")
	Header.Text:SetPoint("LEFT", Header, 4, -0.5)
	Header.Text:SetSize(124, 12)
	Header.Text:SetFont(Font, 12)
	Header.Text:SetJustifyH("LEFT")
	Header.Text:SetShadowColor(0, 0, 0)
	Header.Text:SetShadowOffset(1, -1)
	Header.Text:SetText(name)
	Header.Text:SetTextColor(0.92, 0.92, 0.08)
	
	Header.IsQueued = CreateFrame("Frame", nil, Header)
	Header.IsQueued:SetSize(130, 18)
	Header.IsQueued:SetPoint("CENTER", Header, 0, 0)
	Header.IsQueued:SetBackdrop(Outline)
	Header.IsQueued:SetBackdropColor(0, 0, 0, 0)
	Header.IsQueued:SetBackdropBorderColor(0.92, 0.92, 0.08)
	Header.IsQueued:Hide()
	
	Header.TankActive = false
	Header.HealerActive = false
	Header.DamageActive = false
	Header.AnnounceTank = true
	Header.AnnounceHealer = true
	Header.AnnounceDPS = true
	
	Header.Reset = function(self)
		self.TankActive = false
		self.HealerActive = false
		self.DamageActive = false
		self.AnnounceTank = true
		self.AnnounceHealer = true
		self.AnnounceDPS = true
		
		self:Hide()
		
		for i = 1, 3 do
			self[i]:Hide()
		end
	end
	
	Header.Enable = function(self)
		self.Disabled = false
		
		self:Update()
		CallToArms:SortHeaders()
		
		if Options.Minimized then
			CallToArms.NumActive = 0
			
			for k, v in pairs(CallToArms.Headers) do
				for i = 1, 3 do
					v[i]:EnableMouse(true)
				end
				
				v:Update()
			end
			
			if (CallToArms.NumActive > 0) then
				CallToArms.Text:SetText(BATTLEGROUND_HOLIDAY .. " (" .. CallToArms.NumActive .. ")")
			else
				CallToArms.Text:SetText(BATTLEGROUND_HOLIDAY)
			end
		end
	end
	
	Header.Disable = function(self)
		self.Disabled = true
		
		self:Reset()
		CallToArms:SortHeaders()
		
		if Options.Minimized then
			CallToArms.NumActive = 0
			
			for k, v in pairs(CallToArms.Headers) do
				for i = 1, 3 do
					v[i]:EnableMouse(true)
				end
				
				v:Update()
			end
			
			if (CallToArms.NumActive > 0) then
				CallToArms.Text:SetText(BATTLEGROUND_HOLIDAY .. " (" .. CallToArms.NumActive .. ")")
			else
				CallToArms.Text:SetText(BATTLEGROUND_HOLIDAY)
			end
		end
	end
	
	Header.Sort = function(self)
		self.LastShown = self
		local NumShown = 0
		
		for i = 1, 3 do
			self[i]:ClearAllPoints()
			
			if self[i]:IsVisible() then
				self[i]:SetPoint("TOPLEFT", self.LastShown, "BOTTOMLEFT", 0, 1)
				
				self.LastShown = self[i]
				
				NumShown = NumShown + 1
			end
		end
		
		self.NumShown = NumShown
		
		if (NumShown > 0) then
			self:Show()
		else
			self:Hide()
		end
		
		if (not Options.Minimized) then
			CallToArms:SortHeaders()
		end
	end
	
	for i = 1, 3 do
		local Bar = CreateFrame("Button", nil, self.VisualParent)
		Bar:SetSize(132, 20)
		Bar:Hide()
		Bar.Ela = 0
		Bar.RoleID = i
		Bar.DungeonID = id
		Bar.SubTypeID = subtypeid
		
		Bar:SetBackdrop(Outline)
		Bar:SetBackdropColor(0, 0, 0, 0)
		Bar:SetBackdropBorderColor(0, 0, 0)
		
		Bar.Texture = Bar:CreateTexture(nil, "ARTWORK")
		Bar.Texture:SetPoint("TOPLEFT", Bar, 1, -1)
		Bar.Texture:SetPoint("BOTTOMRIGHT", Bar, -1, 1)
		Bar.Texture:SetTexture(BlankTex)
		Bar.Texture:SetVertexColor(0.3, 0.3, 0.3)
		
		Bar.IconBG = Bar:CreateTexture(nil, "ARTWORK")
		Bar.IconBG:SetSize(20, 20)
		Bar.IconBG:SetPoint("LEFT", Bar, "LEFT", 0, 0)
		Bar.IconBG:SetTexture(BlankTex)
		Bar.IconBG:SetVertexColor(0, 0, 0)
		
		Bar.Icon = Bar:CreateTexture(nil, "OVERLAY")
		Bar.Icon:SetSize(18, 18)
		Bar.Icon:SetPoint("LEFT", Bar, "LEFT", 1, 0)
		Bar.Icon:SetTexture(RoleIcons[i])
		Bar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		
		Bar.MouseOver = Bar:CreateTexture(nil, "OVERLAY")
		Bar.MouseOver:SetSize(111, 18)
		Bar.MouseOver:SetPoint("RIGHT", Bar, "RIGHT", -1, 0)
		Bar.MouseOver:SetTexture(BarTex)
		Bar.MouseOver:SetVertexColor(0.8, 0.8, 0.8, 0.5)
		Bar.MouseOver:SetAlpha(0)
		
		Bar.Flash = Bar:CreateTexture(nil, "OVERLAY")
		Bar.Flash:SetSize(130, 18)
		Bar.Flash:SetPoint("CENTER", Bar, "CENTER", 0, 0)
		Bar.Flash:SetTexture(BarTex)
		Bar.Flash:SetVertexColor(0.8, 0.8, 0.8)
		Bar.Flash:SetAlpha(0)
		
		Bar.FlashAnim = CreateAnimationGroup(Bar.Flash)
		
		Bar.FlashAnim.In1 = Bar.FlashAnim:CreateAnimation("Fade")
		Bar.FlashAnim.In1:SetChange(1)
		Bar.FlashAnim.In1:SetDuration(0.4)
		Bar.FlashAnim.In1:SetEasing("inout")
		Bar.FlashAnim.In1:SetOrder(1)
		
		Bar.FlashAnim.Out1 = Bar.FlashAnim:CreateAnimation("Fade")
		Bar.FlashAnim.Out1:SetChange(-1)
		Bar.FlashAnim.Out1:SetDuration(0.4)
		Bar.FlashAnim.Out1:SetEasing("inout")
		Bar.FlashAnim.Out1:SetOrder(2)
		
		Bar.FlashAnim.In2 = Bar.FlashAnim:CreateAnimation("Fade")
		Bar.FlashAnim.In2:SetChange(1)
		Bar.FlashAnim.In2:SetDuration(0.4)
		Bar.FlashAnim.In2:SetEasing("inout")
		Bar.FlashAnim.In2:SetOrder(3)
		
		Bar.FlashAnim.Out2 = Bar.FlashAnim:CreateAnimation("Fade")
		Bar.FlashAnim.Out2:SetChange(-1)
		Bar.FlashAnim.Out2:SetDuration(0.4)
		Bar.FlashAnim.Out2:SetEasing("inout")
		Bar.FlashAnim.Out2:SetOrder(4)
		
		Bar.FlashAnim.In3 = Bar.FlashAnim:CreateAnimation("Fade")
		Bar.FlashAnim.In3:SetChange(1)
		Bar.FlashAnim.In3:SetDuration(0.4)
		Bar.FlashAnim.In3:SetEasing("inout")
		Bar.FlashAnim.In3:SetOrder(5)
		
		Bar.FlashAnim.Out3 = Bar.FlashAnim:CreateAnimation("Fade")
		Bar.FlashAnim.Out3:SetChange(-1)
		Bar.FlashAnim.Out3:SetDuration(0.4)
		Bar.FlashAnim.Out3:SetEasing("inout")
		Bar.FlashAnim.Out3:SetOrder(6)
		
		Bar.FlashAnim.Width = Bar.FlashAnim:CreateAnimation("Width")
		Bar.FlashAnim.Width:SetChange(200)
		Bar.FlashAnim.Width:SetDuration(0.4)
		Bar.FlashAnim.Width:SetEasing("out")
		Bar.FlashAnim.Width:SetOrder(6)
		
		Bar.FlashAnim.Height = Bar.FlashAnim:CreateAnimation("Height")
		Bar.FlashAnim.Height:SetChange(40)
		Bar.FlashAnim.Height:SetDuration(0.4)
		Bar.FlashAnim.Height:SetEasing("out")
		Bar.FlashAnim.Height:SetOrder(6)
		
		Bar.Text = Bar:CreateFontString(nil, "OVERLAY")
		Bar.Text:SetPoint("LEFT", Bar, 24, -0.5)
		Bar.Text:SetFont(Font, 12)
		Bar.Text:SetJustifyH("LEFT")
		Bar.Text:SetShadowColor(0, 0, 0)
		Bar.Text:SetShadowOffset(1, -1)
		Bar.Text:SetText(RolesName[i])
		Bar.Text:SetTextColor(0.92, 0.92, 0.92)
		
		Bar:RegisterForClicks("AnyUp")
		Bar:SetScript("OnShow", OnShow)
		Bar:SetScript("OnClick", OnClick)
		Bar:SetScript("OnEnter", OnEnter)
		Bar:SetScript("OnLeave", OnLeave)
		
		if (i == 1) then
			Bar:SetPoint("TOPLEFT", Header, "BOTTOMLEFT", 0, -1)
		else
			Bar:SetPoint("TOP", Header[i-1], "BOTTOM", 0, -1)
		end
		
		Header[i] = Bar
	end
	
	self.NumHeaders = self.NumHeaders + 1
	
	self.Headers[name] = Header
	self.HeadersByIndex[self.NumHeaders] = Header
end

local EditBoxOnEnterPressed = function(self)
	self:SetAutoFocus(false)
	self:ClearFocus()
	
	local Value = tonumber(self:GetText())
	
	if (Value > self.Max) then
		Value = self.Max
	elseif (Value < self.Min) then
		Value = self.Min
	end
	
	self:SetText(Value)
	self.Hook(Value)
end

local EditBoxOnMouseDown = function(self)
	self:SetAutoFocus(true)
end

local EditBoxOnEditFocusLost = function(self)
	self:SetAutoFocus(false)
end

local EditBoxOnMouseWheel = function(self, delta)
	local Value = tonumber(self:GetText())
	
	if (delta > 0) then
		Value = Value + self.Step
		
		if (Value > self.Max) then
			Value = self.Max
		end
	else
		Value = Value - self.Step
		
		if (Value < self.Min) then
			Value = self.Min
		end
	end
	
	self:SetText(Value)
	self.Hook(Value)
end

local CreateCTAConfig = function()
	local Config = CreateFrame("Frame", "CallToArmsConfig", UIParent)
	Config:SetSize(200, 18)
	Config:SetPoint("CENTER", UIParent, 0, 160)
	Config:SetMovable(true)
	Config:EnableMouse(true)
	Config:SetUserPlaced(true)
	Config:RegisterForDrag("LeftButton")
	Config:SetScript("OnDragStart", Config.StartMoving)
	Config:SetScript("OnDragStop", Config.StopMovingOrSizing)
	
	Config.BG = Config:CreateTexture(nil, "BORDER")
	Config.BG:SetPoint("TOPLEFT", Config, -1, 1)
	Config.BG:SetPoint("BOTTOMRIGHT", Config, 1, -1)
	Config.BG:SetTexture(BlankTex)
	Config.BG:SetVertexColor(0, 0, 0)
	
	Config.Texture = Config:CreateTexture(nil, "OVERLAY")
	Config.Texture:SetPoint("TOPLEFT", Config, 0, 0)
	Config.Texture:SetPoint("BOTTOMRIGHT", Config, 0, 0)
	Config.Texture:SetTexture(BarTex)
	Config.Texture:SetVertexColor(0.2, 0.2, 0.2)
	
	Config.Text = Config:CreateFontString(nil, "OVERLAY")
	Config.Text:SetPoint("LEFT", Config, 3, -0.5)
	Config.Text:SetFont(Font, 12)
	Config.Text:SetJustifyH("LEFT")
	Config.Text:SetShadowColor(0, 0, 0)
	Config.Text:SetShadowOffset(1, -1)
	Config.Text:SetText(BATTLEGROUND_HOLIDAY .. " " .. GetAddOnMetadata("CallToArms", "Version"))
	
	Config.CloseButton = CreateFrame("Frame", nil, Config)
	Config.CloseButton:SetPoint("TOPRIGHT", Config, 0, 0)
	Config.CloseButton:SetSize(18, 18)
	Config.CloseButton:SetScript("OnEnter", function(self) self.Label:SetVertexColor(1, 0, 0) end)
	Config.CloseButton:SetScript("OnLeave", function(self) self.Label:SetVertexColor(1, 1, 1) end)
	Config.CloseButton:SetScript("OnMouseUp", function() Config:Hide() end)
	
	Config.CloseButton.Label = Config.CloseButton:CreateTexture(nil, "OVERLAY")
	Config.CloseButton.Label:SetPoint("CENTER", Config.CloseButton, 0, -0.5)
	Config.CloseButton.Label:SetTexture("Interface\\AddOns\\CallToArms\\vUIClose.tga")
	
	local ConfigWindow = CreateFrame("Frame", nil, Config)
	ConfigWindow:SetSize(200, 240)
	ConfigWindow:SetPoint("TOPLEFT", Config, "BOTTOMLEFT", 0, -4)
	
	ConfigWindow.Backdrop = ConfigWindow:CreateTexture(nil, "BORDER")
	ConfigWindow.Backdrop:SetPoint("TOPLEFT", ConfigWindow, -1, 1)
	ConfigWindow.Backdrop:SetPoint("BOTTOMRIGHT", ConfigWindow, 1, -1)
	ConfigWindow.Backdrop:SetTexture(BlankTex)
	ConfigWindow.Backdrop:SetVertexColor(0, 0, 0)
	
	ConfigWindow.Inside = ConfigWindow:CreateTexture(nil, "BORDER")
	ConfigWindow.Inside:SetAllPoints()
	ConfigWindow.Inside:SetTexture(BlankTex)
	ConfigWindow.Inside:SetVertexColor(0.3, 0.3, 0.3)
	
	ConfigWindow.ButtonParent = CreateFrame("Frame", nil, ConfigWindow)
	ConfigWindow.ButtonParent:SetAllPoints()
	ConfigWindow.ButtonParent:SetFrameLevel(ConfigWindow:GetFrameLevel() + 4)
	ConfigWindow.ButtonParent:SetFrameStrata("HIGH")
	ConfigWindow.ButtonParent:EnableMouse(true)
	
	ConfigWindow.Backdrop = CreateFrame("Frame", nil, ConfigWindow)
	ConfigWindow.Backdrop:SetPoint("TOPLEFT", Config, -4, 4)
	ConfigWindow.Backdrop:SetPoint("BOTTOMRIGHT", ConfigWindow, 4, -4)
	ConfigWindow.Backdrop:SetBackdrop(Outline)
	ConfigWindow.Backdrop:SetBackdropColor(0.2, 0.2, 0.2)
	ConfigWindow.Backdrop:SetBackdropBorderColor(0, 0, 0)
	ConfigWindow.Backdrop:SetFrameStrata("LOW")
	
	-- Update intervals
	local UpdateIntOption = CreateFrame("Frame", nil, ConfigWindow.ButtonParent)
	UpdateIntOption:SetSize(40, 20)
	UpdateIntOption:SetPoint("TOPLEFT", ConfigWindow.ButtonParent, 3, -3)
	
	UpdateIntOption.BG = UpdateIntOption:CreateTexture(nil, "BORDER")
	UpdateIntOption.BG:SetTexture(BlankTex)
	UpdateIntOption.BG:SetVertexColor(0, 0, 0)
	UpdateIntOption.BG:SetPoint("TOPLEFT", UpdateIntOption, 0, 0)
	UpdateIntOption.BG:SetPoint("BOTTOMRIGHT", UpdateIntOption, 0, 0)
	
	UpdateIntOption.Tex = UpdateIntOption:CreateTexture(nil, "OVERLAY")
	UpdateIntOption.Tex:SetTexture(BarTex)
	UpdateIntOption.Tex:SetPoint("TOPLEFT", UpdateIntOption, 1, -1)
	UpdateIntOption.Tex:SetPoint("BOTTOMRIGHT", UpdateIntOption, -1, 1)
	UpdateIntOption.Tex:SetVertexColor(0.2, 0.2, 0.2)
	
	UpdateIntOption.Text = UpdateIntOption:CreateFontString(nil, "OVERLAY")
	UpdateIntOption.Text:SetFont(Font, 12)
	UpdateIntOption.Text:SetPoint("LEFT", UpdateIntOption, "RIGHT", 3, 0)
	UpdateIntOption.Text:SetJustifyH("LEFT")
	UpdateIntOption.Text:SetShadowColor(0, 0, 0)
	UpdateIntOption.Text:SetShadowOffset(1, -1)
	UpdateIntOption.Text:SetText("Set update interval (seconds)")
	
	UpdateIntOption.EditBox = CreateFrame("EditBox", nil, UpdateIntOption)
	UpdateIntOption.EditBox:SetFont(Font, 12)
	UpdateIntOption.EditBox:SetShadowColor(0, 0, 0)
	UpdateIntOption.EditBox:SetShadowOffset(1, -1)
	UpdateIntOption.EditBox:SetPoint("TOPLEFT", UpdateIntOption, 4, -2)
	UpdateIntOption.EditBox:SetPoint("BOTTOMRIGHT", UpdateIntOption, -2, 2)
	UpdateIntOption.EditBox:SetMaxLetters(3)
	UpdateIntOption.EditBox:SetAutoFocus(false)
	UpdateIntOption.EditBox:EnableKeyboard(true)
	UpdateIntOption.EditBox:EnableMouse(true)
	UpdateIntOption.EditBox:EnableMouseWheel(true)
	UpdateIntOption.EditBox:SetText(Options.UpdateInterval)
	UpdateIntOption.EditBox:SetScript("OnMouseWheel", EditBoxOnMouseWheel)
	UpdateIntOption.EditBox:SetScript("OnMouseDown", EditBoxOnMouseDown)
	UpdateIntOption.EditBox:SetScript("OnEscapePressed", EditBoxOnEnterPressed)
	UpdateIntOption.EditBox:SetScript("OnEnterPressed", EditBoxOnEnterPressed)
	UpdateIntOption.EditBox:SetScript("OnEditFocusLost", EditBoxOnEditFocusLost)
	UpdateIntOption.EditBox.Min = 20
	UpdateIntOption.EditBox.Max = 120
	UpdateIntOption.EditBox.Step = 1
	
	UpdateIntOption.EditBox.Hook = function(value)
		UpdateInt = value
		Options.UpdateInterval = value
		CallToArms.UpdateInterval = value
	end
	
	-- Window alpha
	local WindowAlphaOption = CreateFrame("Frame", nil, ConfigWindow.ButtonParent)
	WindowAlphaOption:SetSize(40, 20)
	WindowAlphaOption:SetPoint("TOPLEFT", UpdateIntOption, "BOTTOMLEFT", 0, -2)
	
	WindowAlphaOption.BG = WindowAlphaOption:CreateTexture(nil, "BORDER")
	WindowAlphaOption.BG:SetTexture(BlankTex)
	WindowAlphaOption.BG:SetVertexColor(0, 0, 0)
	WindowAlphaOption.BG:SetPoint("TOPLEFT", WindowAlphaOption, 0, 0)
	WindowAlphaOption.BG:SetPoint("BOTTOMRIGHT", WindowAlphaOption, 0, 0)
	
	WindowAlphaOption.Tex = WindowAlphaOption:CreateTexture(nil, "OVERLAY")
	WindowAlphaOption.Tex:SetTexture(BarTex)
	WindowAlphaOption.Tex:SetPoint("TOPLEFT", WindowAlphaOption, 1, -1)
	WindowAlphaOption.Tex:SetPoint("BOTTOMRIGHT", WindowAlphaOption, -1, 1)
	WindowAlphaOption.Tex:SetVertexColor(0.2, 0.2, 0.2)
	
	WindowAlphaOption.Text = WindowAlphaOption:CreateFontString(nil, "OVERLAY")
	WindowAlphaOption.Text:SetFont(Font, 12)
	WindowAlphaOption.Text:SetPoint("LEFT", WindowAlphaOption, "RIGHT", 3, 0)
	WindowAlphaOption.Text:SetJustifyH("LEFT")
	WindowAlphaOption.Text:SetShadowColor(0, 0, 0)
	WindowAlphaOption.Text:SetShadowOffset(1, -1)
	WindowAlphaOption.Text:SetText("Set window transparency")
	
	WindowAlphaOption.EditBox = CreateFrame("EditBox", nil, WindowAlphaOption)
	WindowAlphaOption.EditBox:SetFont(Font, 12)
	WindowAlphaOption.EditBox:SetShadowColor(0, 0, 0)
	WindowAlphaOption.EditBox:SetShadowOffset(1, -1)
	WindowAlphaOption.EditBox:SetPoint("TOPLEFT", WindowAlphaOption, 4, -2)
	WindowAlphaOption.EditBox:SetPoint("BOTTOMRIGHT", WindowAlphaOption, -2, 2)
	WindowAlphaOption.EditBox:SetMaxLetters(3)
	WindowAlphaOption.EditBox:SetAutoFocus(false)
	WindowAlphaOption.EditBox:EnableKeyboard(true)
	WindowAlphaOption.EditBox:EnableMouse(true)
	WindowAlphaOption.EditBox:EnableMouseWheel(true)
	WindowAlphaOption.EditBox:SetText(Options.WindowAlpha)
	WindowAlphaOption.EditBox:SetScript("OnMouseWheel", EditBoxOnMouseWheel)
	WindowAlphaOption.EditBox:SetScript("OnMouseDown", EditBoxOnMouseDown)
	WindowAlphaOption.EditBox:SetScript("OnEscapePressed", EditBoxOnEnterPressed)
	WindowAlphaOption.EditBox:SetScript("OnEnterPressed", EditBoxOnEnterPressed)
	WindowAlphaOption.EditBox:SetScript("OnEditFocusLost", EditBoxOnEditFocusLost)
	WindowAlphaOption.EditBox.Min = 0
	WindowAlphaOption.EditBox.Max = 1
	WindowAlphaOption.EditBox.Step = 0.1
	
	WindowAlphaOption.EditBox.Hook = function(value)
		Options.WindowAlpha = value
		CallToArms.WindowAlpha = value
		
		CallToArms:UpdateAlpha(value)
	end
	
	ConfigWindow.Boxes = {}
	
	for i = 1, 4 do
		local Checkbox = CreateFrame("Frame", nil, ConfigWindow.ButtonParent)
		Checkbox:SetSize(20, 20)
		
		Checkbox.BG = Checkbox:CreateTexture(nil, "BORDER")
		Checkbox.BG:SetTexture(BlankTex)
		Checkbox.BG:SetVertexColor(0, 0, 0)
		Checkbox.BG:SetPoint("TOPLEFT", Checkbox, 0, 0)
		Checkbox.BG:SetPoint("BOTTOMRIGHT", Checkbox, 0, 0)
		
		Checkbox.Tex = Checkbox:CreateTexture(nil, "OVERLAY")
		Checkbox.Tex:SetTexture(BarTex)
		Checkbox.Tex:SetPoint("TOPLEFT", Checkbox, 1, -1)
		Checkbox.Tex:SetPoint("BOTTOMRIGHT", Checkbox, -1, 1)
		
		Checkbox.Text = Checkbox:CreateFontString(nil, "OVERLAY")
		Checkbox.Text:SetFont(Font, 12)
		Checkbox.Text:SetPoint("LEFT", Checkbox, "RIGHT", 3, 0)
		Checkbox.Text:SetJustifyH("LEFT")
		Checkbox.Text:SetShadowColor(0, 0, 0)
		Checkbox.Text:SetShadowOffset(1, -1)
		
		if (i == 1) then
			Checkbox:SetPoint("TOPLEFT", WindowAlphaOption, "BOTTOMLEFT", 0, -2)
		else
			Checkbox:SetPoint("TOPLEFT", ConfigWindow.Boxes[i-1], "BOTTOMLEFT", 0, -2)
		end
		
		ConfigWindow.Boxes[i] = Checkbox
	end
	
	if Options.AnnounceStart then
		ConfigWindow.Boxes[1].Tex:SetVertexColor(0, 0.8, 0)
	else
		ConfigWindow.Boxes[1].Tex:SetVertexColor(0.8, 0, 0)
	end
	
	if Options.AnnounceEndings then
		ConfigWindow.Boxes[2].Tex:SetVertexColor(0, 0.8, 0)
	else
		ConfigWindow.Boxes[2].Tex:SetVertexColor(0.8, 0, 0)
	end
	
	if Options.FilterRole then
		ConfigWindow.Boxes[3].Tex:SetVertexColor(0, 0.8, 0)
	else
		ConfigWindow.Boxes[3].Tex:SetVertexColor(0.8, 0, 0)
	end
	
	if Options.MinimizeInGroup then
		ConfigWindow.Boxes[4].Tex:SetVertexColor(0, 0.8, 0)
	else
		ConfigWindow.Boxes[4].Tex:SetVertexColor(0.8, 0, 0)
	end
	
	ConfigWindow.Boxes[1].Text:SetText("Announce bonuses beginning")
	ConfigWindow.Boxes[1]:SetScript("OnMouseUp", function(self)
		if Options.AnnounceStart then
			CallToArms.AnnounceStart = false
			Options.AnnounceStart = false
			
			self.Tex:SetVertexColor(0.8, 0, 0)
		else
			CallToArms.AnnounceStart = true
			Options.AnnounceStart = true
			
			self.Tex:SetVertexColor(0, 0.8, 0)
		end
	end)
	
	ConfigWindow.Boxes[2].Text:SetText("Announce bonuses ending")
	ConfigWindow.Boxes[2]:SetScript("OnMouseUp", function(self)
		if Options.AnnounceEndings then
			CallToArms.AnnounceEndings = false
			Options.AnnounceEndings = false
			
			self.Tex:SetVertexColor(0.8, 0, 0)
		else
			CallToArms.AnnounceEndings = true
			Options.AnnounceEndings = true
			
			self.Tex:SetVertexColor(0, 0.8, 0)
		end
	end)
	
	ConfigWindow.Boxes[3].Text:SetText("Filter roles you cannot perform")
	ConfigWindow.Boxes[3]:SetScript("OnMouseUp", function(self)
		if Options.FilterRole then
			CallToArms.FilterRole = false
			Options.FilterRole = false
			
			self.Tex:SetVertexColor(0.8, 0, 0)
			
			CallToArms:LFG_UPDATE_RANDOM_INFO()
		else
			CallToArms.FilterRole = true
			Options.FilterRole = true
			
			self.Tex:SetVertexColor(0, 0.8, 0)
			
			for k, v in pairs(CallToArms.Headers) do
				v:FilterUpdate()
			end
		end
		
		if (not Options.Minimized) then
			CallToArms:SortHeaders()
		end
	end)
	
	ConfigWindow.Boxes[4].Text:SetText("Auto minimize in groups")
	ConfigWindow.Boxes[4]:SetScript("OnMouseUp", function(self)
		if Options.MinimizeInGroup then
			CallToArms.MinimizeInGroup = false
			Options.MinimizeInGroup = false
			
			self.Tex:SetVertexColor(0.8, 0, 0)
			
			CallToArms:RegisterEvent("GROUP_ROSTER_UPDATE")
		else
			CallToArms.MinimizeInGroup = true
			Options.MinimizeInGroup = true
			
			self.Tex:SetVertexColor(0, 0.8, 0)
			
			CallToArms:UnregisterEvent("GROUP_ROSTER_UPDATE")
		end
	end)
	
	local Div = ConfigWindow.ButtonParent:CreateTexture(nil, "OVERLAY")
	Div:SetSize(194, 1)
	Div:SetPoint("TOP", ConfigWindow.ButtonParent, 0, -136)
	Div:SetTexture(BlankTex)
	Div:SetVertexColor(0, 0, 0)
	
	local ModuleEnables = {}
	
	for i = 1, CallToArms.NumHeaders do
		local DungeonName = CallToArms.HeadersByIndex[i].DungeonName
		
		local Checkbox = CreateFrame("Frame", nil, ConfigWindow.ButtonParent)
		Checkbox:SetSize(20, 20)
		Checkbox.DungeonName = DungeonName
		Checkbox.Index = i
		
		Checkbox.BG = Checkbox:CreateTexture(nil, "BORDER")
		Checkbox.BG:SetTexture(BlankTex)
		Checkbox.BG:SetVertexColor(0, 0, 0)
		Checkbox.BG:SetPoint("TOPLEFT", Checkbox, 0, 0)
		Checkbox.BG:SetPoint("BOTTOMRIGHT", Checkbox, 0, 0)
		
		Checkbox.Tex = Checkbox:CreateTexture(nil, "OVERLAY")
		Checkbox.Tex:SetTexture(BarTex)
		Checkbox.Tex:SetPoint("TOPLEFT", Checkbox, 1, -1)
		Checkbox.Tex:SetPoint("BOTTOMRIGHT", Checkbox, -1, 1)
		
		Checkbox.Text = Checkbox:CreateFontString(nil, "OVERLAY")
		Checkbox.Text:SetFont(Font, 12)
		Checkbox.Text:SetPoint("LEFT", Checkbox, "RIGHT", 3, 0)
		Checkbox.Text:SetSize(ConfigWindow:GetWidth() - 29, 12)
		Checkbox.Text:SetJustifyH("LEFT")
		Checkbox.Text:SetShadowColor(0, 0, 0)
		Checkbox.Text:SetShadowOffset(1, -1)
		Checkbox.Text:SetText(DungeonName)
		
		if (CallToArms["Enable"..DungeonName] ~= true) then
			CallToArms["Enable"..DungeonName] = true
		end
		
		if (CallToArms["Enable"..DungeonName] == true) then
			Checkbox.Tex:SetVertexColor(0, 0.8, 0)
		else
			Checkbox.Tex:SetVertexColor(0.8, 0, 0)
		end
		
		Checkbox:SetScript("OnMouseUp", function(self)
			if (CallToArms["Enable"..self.DungeonName] == true) then
				CallToArms["Enable"..self.DungeonName] = false
				
				CallToArms.HeadersByIndex[self.Index]:Disable()
				
				self.Tex:SetVertexColor(0.8, 0, 0)
			else
				CallToArms["Enable"..self.DungeonName] = true
				
				CallToArms.HeadersByIndex[self.Index]:Enable()
				
				self.Tex:SetVertexColor(0, 0.8, 0)
			end
		end)
		
		if (i == 1) then
			Checkbox:SetPoint("TOPLEFT", ConfigWindow.Boxes[4], "BOTTOMLEFT", 0, -7)
		else
			Checkbox:SetPoint("TOPLEFT", ModuleEnables[i-1], "BOTTOMLEFT", 0, -2)
		end
		
		ModuleEnables[i] = Checkbox
	end
	
	local Height = ((6 + CallToArms.NumHeaders) * 22) + 9
	
	ConfigWindow:SetHeight(Height)
end

local SlashCommand = function(cmd)
	if (cmd == "toggle") then
		if CallToArms:IsShown() then
			CallToArms:Hide()
		else
			CallToArms:Show()
		end
	elseif (cmd == "config") then
		if (not CallToArmsConfig) then
			CreateCTAConfig()
			
			return
		end
		
		if CallToArmsConfig:IsShown() then
			CallToArmsConfig:Hide()
		else
			CallToArmsConfig:Show()
		end
	else
		if CallToArms:IsShown() then
			CallToArms:Hide()
		else
			CallToArms:Show()
		end
	end
end

SLASH_CALLTOARMS1 = "/cta"
SlashCmdList["CALLTOARMS"] = SlashCommand