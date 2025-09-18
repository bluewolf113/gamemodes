
local PANEL = {}

local attribDescriptors = { [-1] = "Impaired",
	[0] = "Diminished",
	[1] = "Functional",
	[2] = "Active",
	[3] = "Conditioned",
	[4] = "Honed",
	[5] = "Exceptional",
	[6] = "Extreme",
	[7] = "Superhuman"
	}

	local skillDescriptors = { [-1] = "Incapable",
	[0] = "Unfamiliar",
	[1] = "Beginner",
	[2] = "Capable",
	[3] = "Professional",
	[4] = "Expert",
	[5] = "Master",
	[6] = "Genius",
	[7] = "Savant"
}

function PANEL:Init()
	local parent = self:GetParent()

	self:SetSize(parent:GetWide() * 0.6, parent:GetTall())
	self:Dock(RIGHT)
	self:DockMargin(0, ScrH() * 0.05, 0, 0)

	self.VBar:SetWide(0)

	-- entry setup
	local suppress = {}
	hook.Run("CanCreateCharacterInfo", suppress)

	if (!suppress.time) then
		local format = ix.option.Get("24hourTime", false) and "%A, %B %d, %Y. %H:%M" or "%A, %B %d, %Y. %I:%M %p"

		self.time = self:Add("DLabel")
		self.time:SetFont("ixMediumFont")
		self.time:SetTall(28)
		self.time:SetContentAlignment(5)
		self.time:Dock(TOP)
		self.time:SetTextColor(color_white)
		self.time:SetExpensiveShadow(1, Color(0, 0, 0, 150))
		self.time:DockMargin(0, 0, 0, 32)
		self.time:SetText(ix.date.GetFormatted(format))
		self.time.Think = function(this)
			if ((this.nextTime or 0) < CurTime()) then
				this:SetText(ix.date.GetFormatted(format))
				this.nextTime = CurTime() + 0.5
			end
		end
	end

	if (!suppress.name) then
		self.name = self:Add("ixLabel")
		self.name:Dock(TOP)
		self.name:DockMargin(0, 0, 0, 8)
		self.name:SetFont("ixMenuButtonHugeFont")
		self.name:SetContentAlignment(5)
		self.name:SetTextColor(color_white)
		self.name:SetPadding(8)
		self.name:SetScaleWidth(true)
	end

	if (!suppress.description) then
		self.description = self:Add("DLabel")
		self.description:Dock(TOP)
		self.description:DockMargin(0, 0, 0, 8)
		self.description:SetFont("ixMenuButtonFont")
		self.description:SetTextColor(color_white)
		self.description:SetContentAlignment(5)
		self.description:SetMouseInputEnabled(true)
		self.description:SetCursor("hand")

		self.description.Paint = function(this, width, height)
			surface.SetDrawColor(0, 0, 0, 150)
			surface.DrawRect(0, 0, width, height)
		end

		self.description.OnMousePressed = function(this, code)
			if (code == MOUSE_LEFT) then
				ix.command.Send("CharDesc")

				if (IsValid(ix.gui.menu)) then
					ix.gui.menu:Remove()
				end
			end
		end

		self.description.SizeToContents = function(this)
			if (this.bWrap) then
				-- sizing contents after initial wrapping does weird things so we'll just ignore (lol)
				return
			end

			local width, height = this:GetContentSize()

			if (width > self:GetWide()) then
				this:SetWide(self:GetWide())
				this:SetTextInset(16, 8)
				this:SetWrap(true)
				this:SizeToContentsY()
				this:SetTall(this:GetTall() + 16) -- eh

				-- wrapping doesn't like middle alignment so we'll do top-center
				self.description:SetContentAlignment(8)
				this.bWrap = true
			else
				this:SetSize(width + 16, height + 16)
			end
		end
	end

	if (!suppress.characterInfo) then
		self.characterInfo = self:Add("Panel")
		self.characterInfo.list = {}
		self.characterInfo:Dock(TOP) -- no dock margin because this is handled by ixListRow
		self.characterInfo.SizeToContents = function(this)
			local height = 0

			for _, v in ipairs(this:GetChildren()) do
				if (IsValid(v) and v:IsVisible()) then
					local _, top, _, bottom = v:GetDockMargin()
					height = height + v:GetTall() + top + bottom
				end
			end

			this:SetTall(height)
		end

		if (!suppress.faction) then
			self.faction = self.characterInfo:Add("ixListRow")
			self.faction:SetList(self.characterInfo.list)
			self.faction:Dock(TOP)
		end

		if (!suppress.class) then
			self.class = self.characterInfo:Add("ixListRow")
			self.class:SetList(self.characterInfo.list)
			self.class:Dock(TOP)
		end

		if (!suppress.money) then
			self.money = self.characterInfo:Add("ixListRow")
			self.money:SetList(self.characterInfo.list)
			self.money:Dock(TOP)
			self.money:SizeToContents()
		end

		hook.Run("CreateCharacterInfo", self.characterInfo)
		self.characterInfo:SizeToContents()
	end

	-- no need to update since we aren't showing the attributes panel
	if (!suppress.attributes) then
		local character = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()

		if (character) then
			local width = math.floor(self:GetWide() / 2)
			self.attsPanel = self:Add("DPanel")
			self.attsPanel:Dock(TOP)
			self.attsPanel:DockMargin(0, 0, 0, 8)
			self.attsPanel:SetSize(width, self:GetParent():GetTall() * 0.4)
		
			self.attsPanel.attributes = self.attsPanel:Add("ixCategoryPanel")
			self.attsPanel.attributes:SetText(L("attributes"))
			self.attsPanel.attributes:Dock(LEFT)
			self.attsPanel.attributes:DockMargin(0, 0, 0, 0)
			self.attsPanel.attributes:SetSize(width)
			
			self.attsPanel.skills = self.attsPanel:Add("ixCategoryPanel")
			self.attsPanel.skills:SetText(L("Skills"))
			self.attsPanel.skills:Dock(RIGHT)
			self.attsPanel.skills:DockMargin(0, 0, 0, 0)
			self.attsPanel.skills:SetSize(width)

			local boost = character:GetBoosts()
			local bFirst = true
			local bFirstSkill = true

			for k, v in SortedPairsByMemberValue(ix.attributes.list, "category") do
				local attributeBoost = 0
				
				local value = character:GetAttribute(k, 0)
				if not (v.bSkill and value == 0) then
					if (boost[k]) then
						for _, bValue in pairs(boost[k]) do
							attributeBoost = attributeBoost + bValue
						end
					end

					local bar = (v.bSkill and self.attsPanel.skills:Add("ixAttributeBar")) or self.attsPanel.attributes:Add("ixAttributeBar")
					bar:Dock(TOP)

					if v.icon then bar:SetIcon(v.icon) end
					
					bar:DockMargin(0, 3, 0, 0)

					-- if (!bFirst or (v.bSkill and !bFirstSkill)) then
						-- bar:DockMargin(0, 3, 0, 0)
					-- else
						-- if not v.bSkill then 
							-- bFirst = false 
						-- else 
							-- v.bFirstSkill = false		
						-- end
					-- end

					if (attributeBoost) then
						bar:SetValue(value - attributeBoost or 0)
					else
						bar:SetValue(value)
					end
					
					

					local maximum = v.maxValue or ix.config.Get("maxAttributes", 100)
					bar:SetMax(maximum)
					bar:SetReadOnly()
					
					local descIndex = (value <= 0 and -1) or (value > maximum and 7) or math.floor((value == 100 and 6) or value / (maximum / 7))
					local descriptor = (v.bSkill and skillDescriptors[descIndex]) or attribDescriptors[descIndex]
					
					-- bar:SetText(Format("%s [%.1f/%.1f] (%.1f%%)", L(v.name), value, maximum, value / maximum * 100))
					bar:SetText(Format("%s [%s] (%.1f%%)", L(v.name), descriptor, value / maximum * 100))
					
					if (attributeBoost) then
						bar:SetBoost(attributeBoost)
					end
					

					self.attsPanel.attributes:SizeToContents()
					self.attsPanel.skills:SizeToContents()
					self.attsPanel:SizeToContents()
				end
			end
		end
	end

	hook.Run("CreateCharacterInfoCategory", self)
end

function PANEL:Update(character)
	if (!character) then
		return
	end

	local faction = ix.faction.indices[character:GetFaction()]
	local class = ix.class.list[character:GetClass()]

	if (self.name) then
		self.name:SetText(character:GetName())

		if (faction) then
			self.name.backgroundColor = ColorAlpha(faction.color, 150) or Color(0, 0, 0, 150)
		end

		self.name:SizeToContents()
	end

	if (self.description) then
		self.description:SetText(character:GetDescription())
		self.description:SizeToContents()
	end

	if (self.faction) then
		self.faction:SetLabelText(L("faction"))
		self.faction:SetText(L(faction.name))
		self.faction:SizeToContents()
	end

	if (self.class) then
		-- don't show class label if the class is the same name as the faction
		if (class and class.name != faction.name) then
			self.class:SetLabelText(L("class"))
			self.class:SetText(L(class.name))
			self.class:SizeToContents()
		else
			self.class:SetVisible(false)
		end
	end

	if (self.money) then
		self.money:SetLabelText(L("money"))
		self.money:SetText(ix.currency.Get(character:GetMoney()))
		self.money:SizeToContents()
	end

	hook.Run("UpdateCharacterInfo", self.characterInfo, character)

	self.characterInfo:SizeToContents()

	hook.Run("UpdateCharacterInfoCategory", self, character)
end

function PANEL:OnSubpanelRightClick()
	properties.OpenEntityMenu(LocalPlayer())
end

vgui.Register("ixCharacterInfo", PANEL, "DScrollPanel")

hook.Add("CreateMenuButtons", "ixCharInfo", function(tabs)
	tabs["you"] = {
		bHideBackground = true,
		buttonColor = team.GetColor(LocalPlayer():Team()),
		Create = function(info, container)
			container.infoPanel = container:Add("ixCharacterInfo")

			container.OnMouseReleased = function(this, key)
				if (key == MOUSE_RIGHT) then
					this.infoPanel:OnSubpanelRightClick()
				end
			end
		end,
		OnSelected = function(info, container)
			container.infoPanel:Update(LocalPlayer():GetCharacter())
			ix.gui.menu:SetCharacterOverview(true)
		end,
		OnDeselected = function(info, container)
			ix.gui.menu:SetCharacterOverview(false)
		end
	}
end)
