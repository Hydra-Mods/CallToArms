local Name, AddOn = ...
local CTA = AddOn.CTA
local L = CTA.L

local SharedMedia = CTA.SharedMedia
local BlankTexture = CTA.BlankTexture
local Outline = {bgFile = BlankTexture}
local DungeonLines = {}
local MaxSelections = 8
local WidgetPage

local OnMouseUp = function(self)
	local ID = self.ID

	self.Checked = not self.Checked

	if self.Checked then
		self.Tex:SetVertexColor(0.7686, 0.7686, 0.3019)
		CallToArmsFilters[ID] = nil
		CTA:debug("Toggled instance " .. self.Name .. " on")
	else
		self.Tex:SetVertexColor(0.125, 0.133, 0.145)
		CallToArmsFilters[ID] = true
		CTA:debug("Toggled instance " .. self.Name .. " off")
	end

	CTA:LFG_UPDATE_RANDOM_INFO()
end

local OnEnter = function(self)
	self.Overlay:Show()

	if self.Description then
		local Tooltip = CTA.Tooltip
		Tooltip:SetOwner(self, "ANCHOR_NONE")
		Tooltip:SetPoint("BOTTOM", self, "TOP", 0, 6)
		Tooltip:ClearLines()
		Tooltip:AddLine(self.Description)
		Tooltip:Show()
	end
end

local OnLeave = function(self)
	self.Overlay:Hide()
	CTA.Tooltip:Hide()
end

local CreateLine = function(page, name, id)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(129, 22)

	local Checkbox = CreateFrame("Frame", nil, Line)
	Checkbox:SetSize(18, 18)
	Checkbox:SetPoint("LEFT", Line, 1, 0)
	Checkbox:SetScript("OnMouseUp", OnMouseUp)
	Checkbox:SetScript("OnEnter", OnEnter)
	Checkbox:SetScript("OnLeave", OnLeave)

	local Tex = Checkbox:CreateTexture(nil, "OVERLAY")
	Tex:SetTexture(BlankTexture)
	Tex:SetPoint("TOPLEFT", Checkbox, 1, -1)
	Tex:SetPoint("BOTTOMRIGHT", Checkbox, -1, 1)

	local Overlay = Checkbox:CreateTexture(nil, "OVERLAY")
	Overlay:SetTexture(BlankTexture)
	Overlay:SetPoint("TOPLEFT", Checkbox, 1, -1)
	Overlay:SetPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Overlay:SetAlpha(0.2)
	Overlay:Hide()

	local Text = Checkbox:CreateFontString(nil, "OVERLAY")
	Text:SetFont(SharedMedia:Fetch("font", CTA.Settings.WindowFont), 12, "")
	Text:SetPoint("LEFT", Checkbox, "RIGHT", 6, 0)
	Text:SetJustifyH("LEFT")
	Text:SetShadowColor(0, 0, 0)
	Text:SetShadowOffset(1, -1)
	Text:SetText(name)

	Checkbox.Tex = Tex
	Checkbox.Overlay = Overlay
	Checkbox.Text = Text
	Checkbox.Name = name
	Checkbox.ID = id

	if CallToArmsFilters[id] then
		Tex:SetVertexColor(0.125, 0.133, 0.145)
		Checkbox.Checked = false
	else
		Tex:SetVertexColor(0.7686, 0.7686, 0.3019)
		Checkbox.Checked = true
	end

	tinsert(DungeonLines, Line)
end

local ScrollSelections = function(self)
	local First = false

	for i = 1, #DungeonLines do
		if (i >= self.Offset) and (i <= self.Offset + MaxSelections - 1) then
			if (not First) then
				DungeonLines[i]:SetPoint("TOPLEFT", WidgetPage, 4, -30)
				First = true
			else
				DungeonLines[i]:SetPoint("TOPLEFT", DungeonLines[i-1], "BOTTOMLEFT", 0, -4)
			end

			DungeonLines[i]:Show()
		else
			DungeonLines[i]:Hide()
		end
	end
end

local ScrollBarOnMouseWheel = function(self, delta)
	if (delta == 1) then
		self.Offset = self.Offset - 1

		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else
		self.Offset = self.Offset + 1

		local MaxOffset = math.max(1, #DungeonLines - (MaxSelections - 1))
		self.Offset = math.min(self.Offset, MaxOffset)
	end

	ScrollSelections(self)
end

local ScrollBarOnValueChanged = function(self)
	self.Offset = self:GetValue()

	ScrollSelections(self)
end

local ScrollBarOnEnter = function(self)
	self:GetThumbTexture():SetVertexColor(0.4, 0.4, 0.4)
end

local ScrollBarOnLeave = function(self)
	if (not self.OverrideThumb) then
		self:GetThumbTexture():SetVertexColor(0.25, 0.266, 0.294)
	end
end

local ScrollBarOnMouseDown = function(self)
	self.OverrideThumb = true
	self:GetThumbTexture():SetVertexColor(0.4, 0.4, 0.4)
end

local ScrollBarOnMouseUp = function(self)
	self.OverrideThumb = false
	self:GetThumbTexture():SetVertexColor(0.25, 0.266, 0.294)
end

function CTA:CreateDungeonsPage(page)
	local Widgets = CreateFrame("Frame", nil, page, "BackdropTemplate")
	Widgets:SetSize(page:GetWidth(), 236)
	Widgets:SetPoint("LEFT", page, 0, 0)
	Widgets:EnableMouse(true)
	Widgets:SetBackdrop(Outline)
	Widgets:SetBackdropColor(0.184, 0.192, 0.211)

	WidgetPage = Widgets

	local QueueBars = self.ActiveQueueBars

	for i = 1, #QueueBars do
		CreateLine(Widgets, QueueBars[i].Name, QueueBars[i].ID)
	end

	self:CreateHeader(Widgets, L["Toggle alerts for specific dungeons"])
	self:SortWidgets(Widgets)

	local ScrollBar = CreateFrame("Slider", nil, Widgets)
	ScrollBar:SetPoint("TOPRIGHT", Widgets, -4, -31)
	ScrollBar:SetPoint("BOTTOMRIGHT", Widgets, -4, 4)
	ScrollBar:SetWidth(10)
	ScrollBar:SetThumbTexture(BlankTexture)
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:SetObeyStepOnDrag(true)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", ScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", ScrollBarOnValueChanged)
	ScrollBar:SetScript("OnEnter", ScrollBarOnEnter)
	ScrollBar:SetScript("OnLeave", ScrollBarOnLeave)
	ScrollBar:SetScript("OnMouseDown", ScrollBarOnMouseDown)
	ScrollBar:SetScript("OnMouseUp", ScrollBarOnMouseUp)
	ScrollBar.Offset = 1

	local MaxOffset = #DungeonLines - MaxSelections + 1

	if (MaxOffset <= 1) then
		ScrollBar:Hide()
		ScrollBar:SetMinMaxValues(1, 1)
	else
		ScrollBar:Show()
		ScrollBar:SetMinMaxValues(1, MaxOffset)
	end

	ScrollBar:SetValue(1)

	local Thumb = ScrollBar:GetThumbTexture()
	Thumb:SetSize(10, 18)
	Thumb:SetVertexColor(0.25, 0.266, 0.294)

	ScrollSelections(ScrollBar)
end