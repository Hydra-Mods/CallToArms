local Name, AddOn = ...
local CTA = AddOn.CTA
local L = CTA.L

local SharedMedia = CTA.SharedMedia
local MaxWidgets = 11
local MaxSelections = 8
local BlankTexture = CTA.BlankTexture
local Outline = {bgFile = BlankTexture}
local ArrowDown = "Interface\\AddOns\\CallToArms\\Assets\\HydraUIArrowDown.tga"
local ArrowUp = "Interface\\AddOns\\CallToArms\\Assets\\HydraUIArrowUp.tga"

function CTA:ShowPage(name)
	local Pages = self.Pages

	for i = 1, #Pages do
		local Page = Pages[i]

		if (Page.Name == name) then
			Page:Show()
			Page.TabHighlight:Show()
		elseif Page:IsShown() then
			Page:Hide()
			Page.TabHighlight:Hide()
		end
	end
end

function CTA:GetPage(name)
	local Pages = self.Pages

	for i = 1, #Pages do
		if (Pages[i].Name == name) then
			return Pages[i]
		end
	end
end

function CTA:PageTabOnEnter()
	self:SetBackdropColor(0.25, 0.266, 0.294)
end

function CTA:PageTabOnLeave()
	self:SetBackdropColor(0.184, 0.192, 0.211)
end

function CTA:PageTabOnMouseUp()
	CTA:ShowPage(self.Name)

	self.Text:ClearAllPoints()
	self.Text:SetPoint("LEFT", self, 5, -0.5)
end

function CTA:PageTabOnMouseDown()
	self.Text:ClearAllPoints()
	self.Text:SetPoint("LEFT", self, 6, -1.5)
end

function CTA:AddPage(name)
	local Tab = CreateFrame("Frame", nil, self.GUI.TabParent, "BackdropTemplate")
	Tab:SetSize(78, 22)
	Tab:SetBackdrop(Outline)
	Tab:SetBackdropColor(0.184, 0.192, 0.211)
	Tab:SetScript("OnEnter", self.PageTabOnEnter)
	Tab:SetScript("OnLeave", self.PageTabOnLeave)
	Tab:SetScript("OnMouseUp", self.PageTabOnMouseUp)
	Tab:SetScript("OnMouseDown", self.PageTabOnMouseDown)
	Tab.Name = name

	local Highlight = Tab:CreateTexture(nil, "OVERLAY")
	Highlight:SetColorTexture(1, 0.7, 0.3)
	Highlight:SetWidth(2)
	Highlight:SetPoint("TOPLEFT", Tab, "TOPLEFT")
	Highlight:SetPoint("BOTTOMLEFT", Tab, "BOTTOMLEFT")
	Highlight:Hide()

	local Text = Tab:CreateFontString(nil, "OVERLAY")
	Text:SetPoint("LEFT", Tab, 5, -0.5)
	Text:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	Text:SetJustifyH("LEFT")
	Text:SetShadowColor(0, 0, 0)
	Text:SetShadowOffset(1, -1)
	Text:SetText(name)

	Tab.Text = Text

	local Page = CreateFrame("Frame", nil, self.GUI.Window)
	Page:SetAllPoints()
	Page.Name = name
	Page.TabHighlight = Highlight

	table.insert(self.Tabs, Tab)
	table.insert(self.Pages, Page)

	return Page
end

function CTA:CreateGUI()
	self.Pages = {}
	self.Tabs = {}

	-- Window
	local GUI = CreateFrame("Frame", "CTA Settings", UIParent, "BackdropTemplate")
	GUI:SetSize(496, 24)
	GUI:SetPoint("CENTER", UIParent, 0, 160)
	GUI:SetMovable(true)
	GUI:EnableMouse(true)
	GUI:SetUserPlaced(true)
	GUI:SetClampedToScreen(true)
	GUI:RegisterForDrag("LeftButton")
	GUI:SetScript("OnDragStart", GUI.StartMoving)
	GUI:SetScript("OnDragStop", GUI.StopMovingOrSizing)
	GUI:SetBackdrop(self.BlankBackdrop)
	GUI:SetBackdropColor(0.184, 0.192, 0.211)
	GUI:SetFrameStrata("DIALOG")
	GUI:SetFrameLevel(20)

	local HeaderText = GUI:CreateFontString(nil, "OVERLAY")
	HeaderText:SetPoint("LEFT", GUI, 6, -0.5)
	HeaderText:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	HeaderText:SetJustifyH("LEFT")
	HeaderText:SetShadowColor(0, 0, 0)
	HeaderText:SetShadowOffset(1, -1)
	HeaderText:SetText("|cffFFC44D" .. L["Call to Arms"] .. "|r " .. (C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata)("CallToArms", "Version"))

	local CloseButton = CreateFrame("Frame", nil, GUI)
	CloseButton:SetPoint("RIGHT", GUI, 0, 0)
	CloseButton:SetSize(24, 24)
	CloseButton:SetScript("OnEnter", function(self) self.Texture:SetVertexColor(1, 0, 0) end)
	CloseButton:SetScript("OnLeave", function(self) self.Texture:SetVertexColor(1, 1, 1) end)
	CloseButton:SetScript("OnMouseUp", function() GUI:Hide() end)

	local CloseTexture = CloseButton:CreateTexture(nil, "OVERLAY")
	CloseTexture:SetPoint("CENTER", CloseButton, 0, -0.5)
	CloseTexture:SetTexture("Interface\\AddOns\\CallToArms\\Assets\\HydraUIClose.tga")

	local TabParent = CreateFrame("Frame", nil, GUI, "BackdropTemplate")
	TabParent:SetSize(86, 236)
	TabParent:SetPoint("TOPLEFT", GUI, "BOTTOMLEFT", 0, -6)
	TabParent:SetBackdrop(self.BlankBackdrop)
	TabParent:SetBackdropColor(0.184, 0.192, 0.211)

	local Window = CreateFrame("Frame", nil, GUI)
	Window:SetSize(403, 236)
	Window:SetPoint("LEFT", TabParent, "RIGHT", 6, 0)

	local Backdrop = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Backdrop:SetPoint("TOPLEFT", GUI, -6, 6)
	Backdrop:SetPoint("BOTTOMRIGHT", Window, 6, -6)
	Backdrop:SetBackdrop(self.BlankBackdrop)
	Backdrop:SetBackdropColor(0.125, 0.133, 0.145)
	Backdrop:SetFrameStrata("BACKGROUND")
	Backdrop:SetFrameLevel(0)

	CloseButton.Texture = CloseTexture
	GUI.TabParent = TabParent
	GUI.Window = Window
	self.GUI = GUI

	local SettingsPage = self:AddPage(L["Settings"])
	self:CreateSettingsPage(SettingsPage)

	local DungeonsPage = self:AddPage(L["Dungeons"])
	self:CreateDungeonsPage(DungeonsPage)

	local HistoryPage = self:AddPage(L["History"])
	self:CreateHistoryPage(HistoryPage)

	for i = 1, #self.Tabs do
		if (i == 1) then
			self.Tabs[i]:SetPoint("TOPLEFT", TabParent, 4, -4)
		else
			self.Tabs[i]:SetPoint("TOPLEFT", self.Tabs[i-1], "BOTTOMLEFT", 0, -4)
		end
	end

	self:ShowPage(L["Settings"])
end

function CTA:SortWidgets(widgets)
	for i = 1, #widgets do
		if (i == 1) then
			widgets[i]:SetPoint("TOPLEFT", widgets, 4, -4)
		else
			widgets[i]:SetPoint("TOPLEFT", widgets[i-1], "BOTTOMLEFT", 0, -4)
		end
	end
end

function CTA:CreateHeader(page, text)
	local Header = CreateFrame("Frame", nil, page, "BackdropTemplate")
	Header:SetSize(page:GetWidth() - 8, 22)
	Header:SetBackdrop(Outline)
	Header:SetBackdropColor(0.25, 0.266, 0.294)

	local Text = Header:CreateFontString(nil, "OVERLAY")
	Text:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	Text:SetPoint("LEFT", Header, 5, -1)
	Text:SetJustifyH("LEFT")
	Text:SetShadowColor(0, 0, 0)
	Text:SetShadowOffset(1, -1)
	Text:SetText(format("|cffFFC44D%s|r", text))

	tinsert(page, Header)
end

function CTA:UpdateSettingValue(key, value)
	if (value == self.Settings[key]) then
		CallToArmsDB[key] = nil
	else
		CallToArmsDB[key] = value
	end

	self.Settings[key] = value
end

function CTA:CheckBoxOnMouseUp()
	if (CTA.Settings[self.Setting] == true) then
		self.Tex:SetVertexColor(0.125, 0.133, 0.145)
		CTA:UpdateSettingValue(self.Setting, false)

		if self.Hook then
			self:Hook(false)
		end
	else
		self.Tex:SetVertexColor(1, 0.7686, 0.3019)
		CTA:UpdateSettingValue(self.Setting, true)

		if self.Hook then
			self:Hook(true)
		end
	end
end

function CTA:CheckBoxOnEnter()
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

function CTA:CheckBoxOnLeave()
	self.Overlay:Hide()
	CTA.Tooltip:Hide()
end

function CTA:CreateCheckbox(page, key, text, tooltip, func)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(129, 22)

	local Checkbox = CreateFrame("Frame", nil, Line)
	Checkbox:SetSize(18, 18)
	Checkbox:SetPoint("LEFT", Line, 1, 0)
	Checkbox:SetScript("OnMouseUp", self.CheckBoxOnMouseUp)
	Checkbox:SetScript("OnEnter", CTA.CheckBoxOnEnter)
	Checkbox:SetScript("OnLeave", CTA.CheckBoxOnLeave)
	Checkbox.Setting = key
	Checkbox.Description = tooltip

	Checkbox.Tex = Checkbox:CreateTexture(nil, "OVERLAY")
	Checkbox.Tex:SetTexture(BlankTexture)
	Checkbox.Tex:SetPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Tex:SetPoint("BOTTOMRIGHT", Checkbox, -1, 1)

	Checkbox.Overlay = Checkbox:CreateTexture(nil, "OVERLAY")
	Checkbox.Overlay:SetTexture(BlankTexture)
	Checkbox.Overlay:SetPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Overlay:SetPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Checkbox.Overlay:SetAlpha(0.2)
	Checkbox.Overlay:Hide()

	Checkbox.Text = Checkbox:CreateFontString(nil, "OVERLAY")
	Checkbox.Text:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	Checkbox.Text:SetPoint("LEFT", Checkbox, "RIGHT", 6, 0)
	Checkbox.Text:SetJustifyH("LEFT")
	Checkbox.Text:SetShadowColor(0, 0, 0)
	Checkbox.Text:SetShadowOffset(1, -1)
	Checkbox.Text:SetText(text)

	if self.Settings[key] then
		Checkbox.Tex:SetVertexColor(1, 0.7686, 0.3019)
	else
		Checkbox.Tex:SetVertexColor(0.125, 0.133, 0.145)
	end

	if func then
		Checkbox.Hook = func
	end

	tinsert(page, Line)
end

local ListOnEnter = function(self)
	self.Tex:SetVertexColor(0.3, 0.3, 0.34)
end

local ListOnLeave = function(self)
	self.Tex:SetVertexColor(0.184, 0.192, 0.211)
end

local WidgetOnLeave = function(self)
	self.Tex:SetVertexColor(0.125, 0.133, 0.145)
end

function CTA:NumberEditBoxOnEnterPressed()
	local Text = self:GetText()

	self:SetAutoFocus(false)
	self:ClearFocus()

	CTA:UpdateSettingValue(self.Setting, tonumber(Text))

	if self.Hook then
		self:Hook(tonumber(Text))
	end
end

function CTA:NumberOnEscapePressed()
	self:SetAutoFocus(false)
	self:ClearFocus()
end

function CTA:NumberEditBoxOnMouseDown()
	self:SetAutoFocus(true)
end

function CTA:NumberOnEnter()
	self.Tex:SetVertexColor(0.3, 0.3, 0.34)

	if self.Description then
		local Tooltip = CTA.Tooltip
		Tooltip:SetOwner(self, "ANCHOR_NONE")
		Tooltip:SetPoint("BOTTOM", self, "TOP", 0, 5)
		Tooltip:ClearLines()
		Tooltip:AddLine(self.Description)
		Tooltip:Show()
	end
end

function CTA:NumberOnLeave()
	self.Tex:SetVertexColor(0.125, 0.133, 0.145)
	CTA.Tooltip:Hide()
end

function CTA:CreateNumberEditBox(page, key, text, tooltip, func)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(page:GetWidth() - 8, 22)

	local EditBox = CreateFrame("EditBox", nil, Line)
	EditBox:SetSize(60, 22)
	EditBox:SetPoint("LEFT", Line, 0, 0)
	EditBox:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	EditBox:SetShadowColor(0, 0, 0)
	EditBox:SetShadowOffset(1, -1)
	EditBox:SetJustifyH("LEFT")
	EditBox:SetAutoFocus(false)
	EditBox:EnableKeyboard(true)
	EditBox:EnableMouse(true)
	EditBox:SetMaxLetters(3)
	EditBox:SetNumeric(true)
	EditBox:SetTextInsets(5, 0, 0, 0)
	EditBox:SetText(self.Settings[key])
	EditBox:SetScript("OnEnterPressed", self.NumberEditBoxOnEnterPressed)
	EditBox:SetScript("OnEscapePressed", self.NumberOnEscapePressed)
	EditBox:SetScript("OnMouseDown", self.NumberEditBoxOnMouseDown)
	EditBox:SetScript("OnEnter", self.NumberOnEnter)
	EditBox:SetScript("OnLeave", self.NumberOnLeave)
	EditBox.Setting = key
	EditBox.Description = tooltip

	EditBox.Tex = EditBox:CreateTexture(nil, "ARTWORK")
	EditBox.Tex:SetTexture(BlankTexture)
	EditBox.Tex:SetPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Tex:SetPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Tex:SetVertexColor(0.125, 0.133, 0.145)

	EditBox.Text = EditBox:CreateFontString(nil, "OVERLAY")
	EditBox.Text:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	EditBox.Text:SetPoint("LEFT", EditBox, "RIGHT", 6, 0)
	EditBox.Text:SetJustifyH("LEFT")
	EditBox.Text:SetShadowColor(0, 0, 0)
	EditBox.Text:SetShadowOffset(1, -1)
	EditBox.Text:SetText(text)

	if func then
		EditBox.Hook = func
	end

	tinsert(page, Line)
end

local ScrollSelections = function(self)
	local First = false

	for i = 1, #self do
		if (i >= self.Offset) and (i <= self.Offset + MaxSelections - 1) then
			if (not First) then
				self[i]:SetPoint("TOPLEFT", self, -1, 1)
				First = true
			else
				self[i]:SetPoint("TOPLEFT", self[i-1], "BOTTOMLEFT", 0, 0)
			end

			self[i]:Show()
		else
			self[i]:Hide()
		end
	end

	if self.ScrollBar then
		self.ScrollBar:SetValue(self.Offset)
	end
end

local SelectionOnMouseWheel = function(self, delta)
	if (delta == 1) then
		self.Offset = self.Offset - 1

		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else
		self.Offset = self.Offset + 1

		if (self.Offset > (#self - (MaxSelections - 1))) then
			self.Offset = self.Offset - 1
		end
	end

	ScrollSelections(self)
end

local SelectionScrollBarOnValueChanged = function(self)
	local Parent = self:GetParent()
	Parent.Offset = self:GetValue()

	ScrollSelections(Parent)
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

local SelectionScrollBarOnMouseWheel = function(self, delta)
	SelectionOnMouseWheel(self:GetParent(), delta)
end

local FontListOnMouseUp = function(self)
	local Selection = self:GetParent():GetParent()

	Selection.Current:SetFont(SharedMedia:Fetch("font", self.Key), 12, "")
	Selection.Current:SetText(self.Key)

	Selection.List:Hide()

	CTA:UpdateSettingValue(Selection.Setting, self.Key)

	if Selection.Hook then
		Selection:Hook(self.Key)
	end

	Selection.Arrow:SetTexture(ArrowDown)
end

local FontSelectionOnMouseUp = function(self)
	if (not self.List) then
		local List = CreateFrame("Frame", nil, self)
		List:SetSize(186, (20 * MaxSelections) - 2) -- 128
		List:SetPoint("TOP", self, "BOTTOM", 0, -1)
		List.Offset = 1
		List:EnableMouseWheel(true)
		List:SetScript("OnMouseWheel", SelectionOnMouseWheel)
		List:SetFrameStrata("TOOLTIP")
		List:SetFrameLevel(20)
		List:Hide()

		local Tex = List:CreateTexture(nil, "ARTWORK")
		Tex:SetTexture(BlankTexture)
		Tex:SetPoint("TOPLEFT", List, -2, 2)
		Tex:SetPoint("BOTTOMRIGHT", List, 2, -2)
		Tex:SetVertexColor(0.125, 0.133, 0.145)

		List.Tex = Tex
		self.List = List

		for Key, Path in next, self.Selections do
			local Selection = CreateFrame("Frame", nil, List)
			Selection:SetSize(176, 20)
			Selection.Key = Key
			Selection.Path = Path
			Selection:SetScript("OnMouseUp", FontListOnMouseUp)
			Selection:SetScript("OnEnter", ListOnEnter)
			Selection:SetScript("OnLeave", ListOnLeave)

			local Tex = Selection:CreateTexture(nil, "ARTWORK")
			Tex:SetTexture(BlankTexture)
			Tex:SetPoint("TOPLEFT", Selection, 1, -1)
			Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
			Tex:SetVertexColor(0.184, 0.192, 0.211)

			local Text = Selection:CreateFontString(nil, "OVERLAY")
			Text:SetFont(Path, 12)
			Text:SetSize(170, 18)
			Text:SetPoint("LEFT", Selection, 5, 0)
			Text:SetJustifyH("LEFT")
			Text:SetShadowColor(0, 0, 0)
			Text:SetShadowOffset(1, -1)
			Text:SetText(Key)

			Selection.Tex = Tex
			Selection.Text = Text

			tinsert(List, Selection)
		end

		table.sort(List, function(a, b)
			return a.Key < b.Key
		end)

		local ScrollBar = CreateFrame("Slider", nil, List)
		ScrollBar:SetPoint("TOPRIGHT", List, 0, 0)
		ScrollBar:SetPoint("BOTTOMRIGHT", List, 0, 0)
		ScrollBar:SetWidth(10)
		ScrollBar:SetThumbTexture(BlankTexture)
		ScrollBar:SetOrientation("VERTICAL")
		ScrollBar:SetValueStep(1)
		ScrollBar:SetMinMaxValues(1, (#List - (MaxSelections - 1)))
		ScrollBar:SetValue(1)
		ScrollBar:SetObeyStepOnDrag(true)
		ScrollBar:EnableMouseWheel(true)
		ScrollBar:SetScript("OnMouseWheel", SelectionScrollBarOnMouseWheel)
		ScrollBar:SetScript("OnValueChanged", SelectionScrollBarOnValueChanged)
		ScrollBar:SetScript("OnEnter", ScrollBarOnEnter)
		ScrollBar:SetScript("OnLeave", ScrollBarOnLeave)
		ScrollBar:SetScript("OnMouseDown", ScrollBarOnMouseDown)
		ScrollBar:SetScript("OnMouseUp", ScrollBarOnMouseUp)

		local Thumb = ScrollBar:GetThumbTexture()
		Thumb:SetSize(10, 18)
		Thumb:SetVertexColor(0.25, 0.266, 0.294)

		List.ScrollBar = ScrollBar

		ScrollSelections(List)
	end

	local List = self.List

	if List:IsShown() then
		List:Hide()
		self.Arrow:SetTexture(ArrowDown)
	else
		List:Show()
		self.Arrow:SetTexture(ArrowUp)
	end
end

function CTA:SelectionOnEnter()
	self.Tex:SetVertexColor(0.3, 0.3, 0.34)

	if self.Description then
		local Tooltip = CTA.Tooltip
		Tooltip:SetOwner(self, "ANCHOR_NONE")
		Tooltip:SetPoint("BOTTOM", self, "TOP", 0, 5)
		Tooltip:ClearLines()
		Tooltip:AddLine(self.Description)
		Tooltip:Show()
	end
end

function CTA:SelectionOnLeave()
	self.Tex:SetVertexColor(0.125, 0.133, 0.145)
	CTA.Tooltip:Hide()
end

function CTA:CreateFontSelection(page, key, text, tooltip, selections, func)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(page:GetWidth() - 8, 22)

	local Selection = CreateFrame("Frame", nil, Line)
	Selection:SetSize(Line:GetWidth(), 22)
	Selection:SetPoint("LEFT", Line, 0, 0)
	Selection:SetScript("OnMouseUp", FontSelectionOnMouseUp)
	Selection:SetScript("OnEnter", self.SelectionOnEnter)
	Selection:SetScript("OnLeave", self.SelectionOnLeave)
	Selection.Selections = selections
	Selection.Setting = key
	Selection.Description = tooltip

	Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
	Selection.Tex:SetTexture(BlankTexture)
	Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
	Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
	Selection.Tex:SetVertexColor(0.125, 0.133, 0.145)

	Selection.Arrow = Selection:CreateTexture(nil, "OVERLAY")
	Selection.Arrow:SetTexture(ArrowDown)
	Selection.Arrow:SetPoint("RIGHT", Selection, -3, 0)
	Selection.Arrow:SetVertexColor(1, 0.7686, 0.3019)

	Selection.Current = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Current:SetFont(SharedMedia:Fetch("font", self.Settings[key]), 12, "")
	Selection.Current:SetSize(122, 18)
	Selection.Current:SetPoint("LEFT", Selection, 5, -0.5)
	Selection.Current:SetJustifyH("LEFT")
	Selection.Current:SetShadowColor(0, 0, 0)
	Selection.Current:SetShadowOffset(1, -1)
	Selection.Current:SetText(self.Settings[key])

	Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Text:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	Selection.Text:SetPoint("LEFT", Selection, "RIGHT", 3, 0)
	Selection.Text:SetJustifyH("LEFT")
	Selection.Text:SetShadowColor(0, 0, 0)
	Selection.Text:SetShadowOffset(1, -1)
	Selection.Text:SetText(text)

	if func then
		Selection.Hook = func
	end

	tinsert(page, Line)
end

local ListOnMouseUp = function(self)
	local Selection = self:GetParent():GetParent()

	Selection.Current:SetText(self.Key)
	Selection.List:Hide()

	CTA:UpdateSettingValue(Selection.Setting, self.Value)

	if Selection.Hook then
		Selection:Hook(self.Value)
	end

	Selection.Arrow:SetTexture(ArrowDown)
end

local SelectionOnMouseUp = function(self)
	if (not self.List) then
		local List = CreateFrame("Frame", nil, self)
		List:SetSize(186, 22 * MaxSelections) -- 128
		List:SetPoint("TOP", self, "BOTTOM", 0, -1)
		List.Offset = 1
		List:EnableMouseWheel(true)
		List:SetScript("OnMouseWheel", SelectionOnMouseWheel)
		List:SetFrameStrata("TOOLTIP")
		List:SetFrameLevel(20)
		List:Hide()

		local Tex = List:CreateTexture(nil, "ARTWORK")
		Tex:SetTexture(BlankTexture)
		Tex:SetPoint("TOPLEFT", List, -2, 2)
		Tex:SetPoint("BOTTOMRIGHT", List, 2, -2)
		Tex:SetVertexColor(0.125, 0.133, 0.145)

		List.Text = Tex
		self.List = List

		for Key, Value in next, self.Selections do
			local Selection = CreateFrame("Frame", nil, List)
			Selection:SetSize(188, 22)
			Selection.Key = Key
			Selection.Value = Value
			Selection:SetScript("OnMouseUp", ListOnMouseUp)
			Selection:SetScript("OnEnter", ListOnEnter)
			Selection:SetScript("OnLeave", ListOnLeave)

			Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
			Selection.Tex:SetTexture(BlankTexture)
			Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
			Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
			Selection.Tex:SetVertexColor(0.184, 0.192, 0.211)

			Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
			Selection.Text:SetFont(SharedMedia:Fetch("font", CTA.Settings["WindowFont"]), 12, "")
			Selection.Text:SetSize(170, 18)
			Selection.Text:SetPoint("LEFT", Selection, 5, 0)
			Selection.Text:SetJustifyH("LEFT")
			Selection.Text:SetShadowColor(0, 0, 0)
			Selection.Text:SetShadowOffset(1, -1)
			Selection.Text:SetText(Key)

			tinsert(List, Selection)
		end

		table.sort(List, function(a, b)
			return a.Key < b.Key
		end)

		if #List > (MaxSelections - 1) then
			local ScrollBar = CreateFrame("Slider", nil, List)
			ScrollBar:SetPoint("TOPLEFT", List, "TOPRIGHT", 0, 0)
			ScrollBar:SetPoint("BOTTOMLEFT", List, "BOTTOMRIGHT", 0, 0)
			ScrollBar:SetWidth(10)
			ScrollBar:SetThumbTexture(BlankTexture)
			ScrollBar:SetOrientation("VERTICAL")
			ScrollBar:SetValueStep(1)
			ScrollBar:SetMinMaxValues(1, (#List - (MaxSelections - 1)))
			ScrollBar:SetValue(1)
			ScrollBar:SetObeyStepOnDrag(true)
			ScrollBar:EnableMouseWheel(true)
			ScrollBar:SetScript("OnMouseWheel", SelectionScrollBarOnMouseWheel)
			ScrollBar:SetScript("OnValueChanged", SelectionScrollBarOnValueChanged)
			ScrollBar:SetScript("OnEnter", ScrollBarOnEnter)
			ScrollBar:SetScript("OnLeave", ScrollBarOnLeave)
			ScrollBar:SetScript("OnMouseDown", ScrollBarOnMouseDown)
			ScrollBar:SetScript("OnMouseUp", ScrollBarOnMouseUp)

			local Thumb = ScrollBar:GetThumbTexture()
			Thumb:SetSize(10, 18)
			Thumb:SetVertexColor(0.25, 0.266, 0.294)

			List.ScrollBar = ScrollBar
		else
			List:SetHeight((22 * #List) - 2)
			List:SetWidth(186)
		end

		ScrollSelections(List)
	end

	if self.List:IsShown() then
		self.List:Hide()
		self.Arrow:SetTexture(ArrowDown)
	else
		self.List:Show()
		self.Arrow:SetTexture(ArrowUp)
	end
end

function CTA:CreateSelection(page, key, text, tooltip, selections, func)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(page:GetWidth() - 8, 22)

	local Selection = CreateFrame("Frame", nil, Line)
	Selection:SetSize(Line:GetWidth(), 22)
	Selection:SetPoint("LEFT", Line, 0, 0)
	Selection:SetScript("OnMouseUp", SelectionOnMouseUp)
	Selection:SetScript("OnEnter", self.SelectionOnEnter)
	Selection:SetScript("OnLeave", self.SelectionOnLeave)
	Selection.Selections = selections
	Selection.Setting = key
	Selection.Description = tooltip

	local Name

	for k, v in next, selections do
		if (v == self.Settings[key]) then
			Name = k
		end
	end

	Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
	Selection.Tex:SetTexture(BlankTexture)
	Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
	Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
	Selection.Tex:SetVertexColor(0.125, 0.133, 0.145)

	Selection.Arrow = Selection:CreateTexture(nil, "OVERLAY")
	Selection.Arrow:SetTexture(ArrowDown)
	Selection.Arrow:SetPoint("RIGHT", Selection, -3, 0)
	Selection.Arrow:SetVertexColor(1, 0.7686, 0.3019)

	Selection.Current = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Current:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	Selection.Current:SetSize(122, 18)
	Selection.Current:SetPoint("LEFT", Selection, 5, -0.5)
	Selection.Current:SetJustifyH("LEFT")
	Selection.Current:SetShadowColor(0, 0, 0)
	Selection.Current:SetShadowOffset(1, -1)
	Selection.Current:SetText(Name)

	Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Text:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	Selection.Text:SetPoint("LEFT", Selection, "RIGHT", 3, 0)
	Selection.Text:SetJustifyH("LEFT")
	Selection.Text:SetShadowColor(0, 0, 0)
	Selection.Text:SetShadowOffset(1, -1)
	Selection.Text:SetText(text)

	if func then
		Selection.Hook = func
	end

	tinsert(page, Line)
end

local UpdateWidgetWidth = function(self, width)
	CTA.Widget:SetWidth(width)

	for key, value in next, CTA.InstanceData do
		value:SetWidth(width)
	end

	for key, value in next, CTA.RecycledHeaders do
		value:SetWidth(width)
	end
end

local UpdateWidgetHeight = function(self, height)
	local IconHeight = height - 2

	CTA.Widget:SetHeight(height)

	for key, value in next, CTA.InstanceData do
		value:SetHeight(height)

		for i = 1, 3 do
			value.RoleButtons[i]:SetSize(IconHeight, IconHeight)
		end
	end

	for key, value in next, CTA.RecycledHeaders do
		value:SetHeight(height)

		for i = 1, 3 do
			value.RoleButtons[i]:SetSize(IconHeight, IconHeight)
		end
	end
end

local UpdateWidgetFont = function(self, font)
	local Font = SharedMedia:Fetch("font", font)

	CTA.Widget.Label:SetFont(Font, 12, "")

	for key, value in next, CTA.InstanceData do
		value.Label:SetFont(Font, 12, "")
	end

	for key, value in next, CTA.RecycledHeaders do
		value.Label:SetFont(Font, 12, "")
	end
end

local UpdateLockWidget = function(self, toggled)
	if toggled then
		CTA:SetScript("OnDragStart", nil)
		CTA:SetScript("OnDragStop", nil)
	else
		CTA:SetScript("OnDragStart", CTA.StartMoving)
		CTA:SetScript("OnDragStop", CTA.StopMovingOrSizing)
	end
end

local UpdateMinimapButton = function(self, toggled)
	local LibDBIcon = LibStub("LibDBIcon-1.0")

	if toggled then
		LibDBIcon:Show(L["Call to Arms"])
	else
		LibDBIcon:Hide(L["Call to Arms"])
	end
end

local UpdateHideInGroup = function()
	CTA:UpdateGroupVisibility()
end

local UpdateIgnoredRoles = function()
	CTA:LFG_UPDATE_RANDOM_INFO()
end

-- Page data
function CTA:CreateSettingsPage(page)
	local LeftWidgets = CreateFrame("Frame", nil, page, "BackdropTemplate")
	LeftWidgets:SetSize(199, 236)
	LeftWidgets:SetPoint("LEFT", page, 0, 0)
	LeftWidgets:EnableMouse(true)
	LeftWidgets:SetBackdrop(Outline)
	LeftWidgets:SetBackdropColor(0.184, 0.192, 0.211)

	local RightWidgets = CreateFrame("Frame", nil, page, "BackdropTemplate")
	RightWidgets:SetSize(198, 236)
	RightWidgets:SetPoint("LEFT", LeftWidgets, "RIGHT", 6, 0)
	RightWidgets:EnableMouse(true)
	RightWidgets:SetBackdrop(Outline)
	RightWidgets:SetBackdropColor(0.184, 0.192, 0.211)

	page.LeftWidgets = LeftWidgets
	page.RightWidgets = RightWidgets

	self:CreateHeader(LeftWidgets, L["Set Font"])
	self:CreateFontSelection(LeftWidgets, "WindowFont", "", L["Select a font."], self.Fonts, UpdateWidgetFont)

	self:CreateHeader(LeftWidgets, L["Window Size"])
	self:CreateNumberEditBox(LeftWidgets, "HeaderWidth", L["Set Width"], L["Set the width of the widget."], UpdateWidgetWidth)
	self:CreateNumberEditBox(LeftWidgets, "HeaderHeight", L["Set Height"], L["Set the height of the widget."], UpdateWidgetHeight)

	self:CreateHeader(LeftWidgets, L["Filter by Role"])
	self:CreateCheckbox(LeftWidgets, "IgnoreTank", TANK, L["Hide alerts for Tank role bonuses."], UpdateIgnoredRoles)
	self:CreateCheckbox(LeftWidgets, "IgnoreHeal", HEALER, L["Hide alerts for Healer role bonuses."], UpdateIgnoredRoles)
	self:CreateCheckbox(LeftWidgets, "IgnoreDamage", DAMAGER, L["Hide alerts for Damage role bonuses."], UpdateIgnoredRoles)

	self:CreateHeader(RightWidgets, L["Visibility"])
	self:CreateCheckbox(RightWidgets, "HideInGroup", L["Hide In Group"], L["Automatically hide the widget when you join a party or raid group."], UpdateHideInGroup)
	self:CreateCheckbox(RightWidgets, "MinimapButton", L["Minimap Button"], L["Toggles the visibility of the minimap button."], UpdateMinimapButton)

	self:CreateHeader(RightWidgets, L["Announcements"])
	self:CreateCheckbox(RightWidgets, "AnnounceStart", L["Bonuses Beginning"], L["Show a chat message when a role bonus becomes available."], function() end)
	self:CreateCheckbox(RightWidgets, "AnnounceEnd", L["Bonuses Ending"], L["Show a chat message when a role bonus ends."], function() end)
	self:CreateCheckbox(RightWidgets, "PlaySound", L["Play Sound"], L["Play a sound when a bonus appears."], function() end)

	self:CreateHeader(RightWidgets, MISCELLANEOUS)
	self:CreateCheckbox(RightWidgets, "LockWidget", L["Lock Widget"], L["Prevents the widget from being moved unless unlocked."], UpdateLockWidget)

	self:SortWidgets(LeftWidgets)
	self:SortWidgets(RightWidgets)
end

function CTA:FormatHistoryEntry(entry)
	local Time = date("%H:%M:%S", entry.Time)
	local Event

	if (entry.State == "start") then
		Event = L["Bonus Available"]
	else
		local Duration = CTA:FormatDuration(entry.Duration or 0)
		Event = format(L["Bonus Ended (%s)"], Duration)
	end

	return format("|cff00ccff[%s]|r |cffffff00[%s]|r — %s %s", Time, entry.Dungeon, entry.Role, Event)
end

function CTA:CreateHistoryPage(page)
	local Parent = CreateFrame("Frame", nil, page, "BackdropTemplate")
	Parent:SetSize(403, 236)
	Parent:SetPoint("LEFT", page, 0, 0)
	Parent:EnableMouse(true)
	Parent:SetBackdrop(Outline)
	Parent:SetBackdropColor(0.184, 0.192, 0.211)

	local Backdrop = CreateFrame("Frame", nil, Parent, "BackdropTemplate")
	Backdrop:SetPoint("TOPLEFT", Parent, 3, -3)
	Backdrop:SetPoint("BOTTOMRIGHT", Parent, -3, 3)
	Backdrop:SetBackdrop(self.BlankBackdrop)
	Backdrop:SetBackdropColor(0.125, 0.133, 0.145, 0.5)

	local HistoryFrame = CreateFrame("ScrollingMessageFrame", nil, Backdrop)
	HistoryFrame:SetPoint("TOPLEFT", Backdrop, 3, -3)
	HistoryFrame:SetPoint("BOTTOMRIGHT", Backdrop, -3, 3)
	HistoryFrame:SetFont(SharedMedia:Fetch("font", self.Settings.WindowFont), 12, "")
	HistoryFrame:SetJustifyH("LEFT")
	HistoryFrame:SetShadowColor(0, 0, 0)
	HistoryFrame:SetShadowOffset(1, -1)
	HistoryFrame:SetFading(false)

	if (#self.History > 0) then
		for i = 1, #self.History do
			local Message = self:FormatHistoryEntry(self.History[i])

			HistoryFrame:AddMessage(Message)
		end
	end

	self.HistoryFrame = HistoryFrame
end

SLASH_CALLTOARMSADDON1 = "/cta"
SLASH_CALLTOARMSADDON2 = "/calltoarms"
SlashCmdList.CALLTOARMSADDON = function(cmd)
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