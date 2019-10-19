local F, C, L = unpack(select(2, ...))
local TOOLTIP = F:RegisterModule('Tooltip')


local strfind, format, strupper, strlen, pairs, unpack = string.find, string.format, string.upper, string.len, pairs, unpack
local ICON_LIST, BAG_ITEM_QUALITY_COLORS = ICON_LIST, BAG_ITEM_QUALITY_COLORS
local PVP, LEVEL, FACTION_HORDE, FACTION_ALLIANCE = PVP, LEVEL, FACTION_HORDE, FACTION_ALLIANCE
local YOU, TARGET, AFK, DND, DEAD, PLAYER_OFFLINE = YOU, TARGET, AFK, DND, DEAD, PLAYER_OFFLINE
local FOREIGN_SERVER_LABEL, INTERACTIVE_SERVER_LABEL = FOREIGN_SERVER_LABEL, INTERACTIVE_SERVER_LABEL
local LE_REALM_RELATION_COALESCED, LE_REALM_RELATION_VIRTUAL = LE_REALM_RELATION_COALESCED, LE_REALM_RELATION_VIRTUAL
local UnitIsPVP, UnitFactionGroup, UnitRealmRelationship = UnitIsPVP, UnitFactionGroup, UnitRealmRelationship
local UnitIsConnected, UnitIsDeadOrGhost, UnitIsAFK, UnitIsDND = UnitIsConnected, UnitIsDeadOrGhost, UnitIsAFK, UnitIsDND
local InCombatLockdown, IsShiftKeyDown, GetMouseFocus, GetItemInfo = InCombatLockdown, IsShiftKeyDown, GetMouseFocus, GetItemInfo
local GetCreatureDifficultyColor, UnitCreatureType, UnitClassification = GetCreatureDifficultyColor, UnitCreatureType, UnitClassification
local UnitIsWildBattlePet, UnitIsBattlePetCompanion, UnitBattlePetLevel = UnitIsWildBattlePet, UnitIsBattlePetCompanion, UnitBattlePetLevel
local UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel = UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel
local GetRaidTargetIndex, GetGuildInfo, IsInGuild = GetRaidTargetIndex, GetGuildInfo, IsInGuild

local classification = {
	elite = ' |cffcc8800'..ELITE..'|r',
	rare = ' |cffff99cc'..L['TOOLTIP_RARE']..'|r',
	rareelite = ' |cffff99cc'..L['TOOLTIP_RARE']..'|r '..'|cffcc8800'..ELITE..'|r',
	worldboss = ' |cffff0000'..BOSS..'|r',
}

function TOOLTIP:GetUnit()
	local _, unit = self and self:GetUnit()
	if not unit then
		local mFocus = GetMouseFocus()
		unit = mFocus and (mFocus.unit or (mFocus.GetAttribute and mFocus:GetAttribute('unit'))) or 'mouseover'
	end
	return unit
end

function TOOLTIP:HideLines()
	for i = 3, self:NumLines() do
		local tiptext = _G['GameTooltipTextLeft'..i]
		local linetext = tiptext:GetText()
		if linetext then
			if linetext == PVP then
				tiptext:SetText(nil)
				tiptext:Hide()
			elseif linetext == FACTION_HORDE then
				tiptext:SetText(nil)
				tiptext:Hide()
			elseif linetext == FACTION_ALLIANCE then
				tiptext:SetText(nil)
				tiptext:Hide()
			end
		end
	end
end

function TOOLTIP:GetLevelLine()
	for i = 2, self:NumLines() do
		local tiptext = _G['GameTooltipTextLeft'..i]
		local linetext = tiptext:GetText()
		if linetext and strfind(linetext, LEVEL) then
			return tiptext
		end
	end
end

function TOOLTIP:GetTarget(unit)
	if UnitIsUnit(unit, 'player') then
		return format('|cffff0000%s|r', '>'..strupper(YOU)..'<')
	else
		return F.HexRGB(F.UnitColor(unit))..UnitName(unit)..'|r'
	end
end

function TOOLTIP:OnTooltipSetUnit()
	if self:IsForbidden() then return end
	if C.tooltip.combatHide and InCombatLockdown() then self:Hide() return end

	TOOLTIP.HideLines(self)

	local unit = TOOLTIP.GetUnit(self)
	local isShiftKeyDown = IsShiftKeyDown()
	if UnitExists(unit) then
		self.ttUnit = unit
		local r, g, b = F.UnitColor(unit)
		local hexColor = F.HexRGB(r, g, b)
		local ricon = GetRaidTargetIndex(unit)
		if ricon and ricon > 8 then ricon = nil end
		--[[if ricon and text then
			GameTooltipTextLeft1:SetFormattedText(('%s %s'), ICON_LIST[ricon]..'18|t', text)
		end--]]

		local isPlayer = UnitIsPlayer(unit)
		if isPlayer then
			local name, realm = UnitName(unit)
			local pvpName = UnitPVPName(unit)
			local relationship = UnitRealmRelationship(unit)
			if not C.tooltip.hideTitle and pvpName then
				name = pvpName
			end
			if realm and realm ~= '' then
				if isShiftKeyDown or not C.tooltip.hideRealm then
					name = name..'-'..realm
				elseif relationship == LE_REALM_RELATION_COALESCED then
					name = name..FOREIGN_SERVER_LABEL
				elseif relationship == LE_REALM_RELATION_VIRTUAL then
					name = name..INTERACTIVE_SERVER_LABEL
				end
			end

			local status = (UnitIsAFK(unit) and AFK) or (UnitIsDND(unit) and DND) or (not UnitIsConnected(unit) and PLAYER_OFFLINE)
			if status then
				status = format(' |cffffcc00[%s]|r', status)
			end
			GameTooltipTextLeft1:SetFormattedText('%s', name..(status or ''))

			local guildName, rank, rankIndex, guildRealm = GetGuildInfo(unit)
			local hasText = GameTooltipTextLeft2:GetText()
			if guildName and hasText then
				local myGuild, _, _, myGuildRealm = GetGuildInfo('player')
				if IsInGuild() and guildName == myGuild and guildRealm == myGuildRealm then
					GameTooltipTextLeft2:SetTextColor(.25, 1, .25)
				else
					GameTooltipTextLeft2:SetTextColor(.6, .8, 1)
				end

				rankIndex = rankIndex + 1
				if C.tooltip.hideRank then rank = '' end
				if guildRealm and isShiftKeyDown then
					guildName = guildName..'-'..guildRealm
				end
				if C.tooltip.hideJunkGuild and not isShiftKeyDown then
					if strlen(guildName) > 31 then guildName = '...' end
				end
				GameTooltipTextLeft2:SetText('<'..guildName..'> '..rank..'('..rankIndex..')')
			end
		end

		local line1 = GameTooltipTextLeft1:GetText()
		GameTooltipTextLeft1:SetFormattedText('%s', hexColor..line1)

		local alive = not UnitIsDeadOrGhost(unit)
		local level = UnitLevel(unit)


		if level then
			local boss
			if level == -1 then boss = '|cffff0000??|r' end

			local diff = GetCreatureDifficultyColor(level)
			local classify = UnitClassification(unit)
			local textLevel = format('%s%s%s|r', F.HexRGB(diff), boss or format('%d', level), classification[classify] or '')
			
			local pvpFlag = isPlayer and UnitIsPVP(unit) and format(' |cffff0000%s|r', PVP) or ''
			local unitClass = isPlayer and format('%s %s', UnitRace(unit) or '', hexColor..(UnitClass(unit) or '')..'|r') or UnitCreatureType(unit) or ''
			local levelString = format(('%s%s %s %s'), textLevel, pvpFlag, unitClass, (not alive and '|cffCCCCCC'..DEAD..'|r' or ''))

			local tiptextLevel = TOOLTIP.GetLevelLine(self)
			if tiptextLevel then
				tiptextLevel:SetText(levelString)
			else
				GameTooltip:AddLine(levelString)
			end
		end

		if UnitExists(unit..'target') then
			local tarRicon = GetRaidTargetIndex(unit..'target')
			if tarRicon and tarRicon > 8 then tarRicon = nil end
			local tar = format('%s%s', (tarRicon and ICON_LIST[tarRicon]..'10|t') or '', TOOLTIP:GetTarget(unit..'target'))
			self:AddLine(TARGET..': '..tar)
		end

		if alive then
			GameTooltipStatusBar:SetStatusBarColor(F.UnitColor(unit))
		else
			GameTooltipStatusBar:Hide()
		end
	else
		GameTooltipStatusBar:SetStatusBarColor(0, .9, 0)
	end

	--TOOLTIP.InspectUnitSpecAndLevel(self)
end

function TOOLTIP:ReskinStatusBar()
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint('BOTTOMLEFT', GameTooltip, 'TOPLEFT', C.Mult, -3)
	GameTooltipStatusBar:SetPoint('BOTTOMRIGHT', GameTooltip, 'TOPRIGHT', -C.Mult, -3)
	GameTooltipStatusBar:SetStatusBarTexture(C.media.sbTex)
	GameTooltipStatusBar:SetHeight(2)
	local bg = F.CreateBDFrame(GameTooltipStatusBar)
	F.CreateSD(bg)
end

function TOOLTIP:GameTooltip_ShowStatusBar()
	if self.statusBarPool then
		local bar = self.statusBarPool:Acquire()
		if bar and not bar.styled then
			F.StripTextures(bar)
			local tex = select(3, bar:GetRegions())
			tex:SetTexture(C.media.sbTex)
			F.CreateBDFrame(bar)

			bar.styled = true
		end
	end
end

function TOOLTIP:GameTooltip_ShowProgressBar()
	if self.progressBarPool then
		local bar = self.progressBarPool:Acquire()
		if bar and not bar.styled then
			F.StripTextures(bar.Bar)
			bar.Bar:SetStatusBarTexture(C.media.sbTex)
			F.CreateBDFrame(bar)
			bar:SetSize(216, 16)
			F.SetFS(bar.Bar.Label)

			bar.styled = true
		end
	end
end


local mover
function TOOLTIP:GameTooltip_SetDefaultAnchor(parent)
	if C.tooltip.cursor then
		self:SetOwner(parent, 'ANCHOR_CURSOR_RIGHT')
	else
		if not mover then
			mover = F.Mover(self, L['MOVER_TOOLTIP'], 'GameTooltip', C.tooltip.position, 240, 120)
		end
		self:SetOwner(parent, 'ANCHOR_NONE')
		self:ClearAllPoints()
		self:SetPoint('BOTTOMRIGHT', mover)
	end
end

function TOOLTIP:ReskinTooltip()
	if not self then
		if C.isDeveloper then print('Unknown tooltip spotted.') end
		return
	end
	if self:IsForbidden() then return end
	--self:SetScale(C.tooltip.scale)

	if not self.tipStyled then
		self:SetBackdrop(nil)
		self:DisableDrawLayer('BACKGROUND')
		local bg = F.CreateBDFrame(self)
		bg:SetFrameLevel(self:GetFrameLevel())
		F.CreateSD(bg, .35)
		self.bg = bg

		-- other gametooltip-like support
		self.GetBackdrop = getBackdrop
		self.GetBackdropColor = getBackdropColor
		self.GetBackdropBorderColor = getBackdropBorderColor

		self.tipStyled = true
	end

	self.bg:SetBackdropBorderColor(0, 0, 0)
	
	if self.bg.Shadow then
		self.bg.Shadow:SetBackdropBorderColor(0, 0, 0, .35)
	end

	if C.tooltip.borderColor and self.GetItem then
		local _, item = self:GetItem()
		if item then
			local quality = select(3, GetItemInfo(item))
			local color = BAG_ITEM_QUALITY_COLORS[quality or 1]
			if color then
				if self.bg.Shadow then
					self.bg.Shadow:SetBackdropBorderColor(color.r, color.g, color.b, .35)
				else
					self.bg:SetBackdropBorderColor(color.r, color.g, color.b)
				end
			end
		end
	end
end

function TOOLTIP:GameTooltip_SetBackdropStyle()
	if not self.tipStyled then return end
	self:SetBackdrop(nil)
end



function TOOLTIP:OnLogin()
	self:ReskinStatusBar()

	local ssbc = CreateFrame('StatusBar').SetStatusBarColor
	GameTooltipStatusBar._SetStatusBarColor = ssbc
	function GameTooltipStatusBar:SetStatusBarColor(...)
		local unit = TOOLTIP.GetUnit(GameTooltip)
		if(UnitExists(unit)) then
			return self:_SetStatusBarColor(F.UnitColor(unit))
		end
	end

	GameTooltip:HookScript('OnTooltipSetUnit', self.OnTooltipSetUnit)

	hooksecurefunc('GameTooltip_ShowStatusBar', self.GameTooltip_ShowStatusBar)
	hooksecurefunc('GameTooltip_ShowProgressBar', self.GameTooltip_ShowProgressBar)
	hooksecurefunc('GameTooltip_SetDefaultAnchor', self.GameTooltip_SetDefaultAnchor)
	hooksecurefunc('GameTooltip_SetBackdropStyle', self.GameTooltip_SetBackdropStyle)

	GameTooltip:HookScript('OnTooltipCleared', function(self)
		self.ttUpdate = 1
		self.ttNumLines = 0
		self.ttUnit = nil
	end)

	GameTooltip:HookScript('OnUpdate', function(self, elapsed)
		self.ttUpdate = (self.ttUpdate or 0) + elapsed
		if(self.ttUpdate < .1) then return end
		if(self.ttUnit and not UnitExists(self.ttUnit)) then self:Hide() return end
		self:SetBackdropColor(0, 0, 0, .5)
		self.ttUpdate = 0
	end)

	GameTooltip.FadeOut = function(self)
		self:Hide()
	end

	GameTooltip_OnTooltipAddMoney = F.Dummy

	self:ReskinTooltipIcons()
	self:LinkHover()
	self:ExtraInfo()
	self:TargetedInfo()
	--self:PetInfo()
	--self:AzeriteTrait()
end


local tipTable = {}
function TOOLTIP:RegisterTooltips(addon, func)
	tipTable[addon] = func
end
local function addonStyled(_, addon)
	if tipTable[addon] then
		tipTable[addon]()
		tipTable[addon] = nil
	end
end
F:RegisterEvent('ADDON_LOADED', addonStyled)

TOOLTIP:RegisterTooltips('FreeUI', function()
	local tooltips = {
		ChatMenu,
		EmoteMenu,
		LanguageMenu,
		VoiceMacroMenu,
		GameTooltip,
		EmbeddedItemTooltip,
		ItemRefTooltip,
		ItemRefShoppingTooltip1,
		ItemRefShoppingTooltip2,
		ShoppingTooltip1,
		ShoppingTooltip2,
		AutoCompleteBox,
		FriendsTooltip,
		GeneralDockManagerOverflowButtonList,
		NamePlateTooltip,
		WorldMapTooltip,
		IMECandidatesFrame
	}
	for _, f in pairs(tooltips) do
		f:HookScript('OnShow', TOOLTIP.ReskinTooltip)
	end

	-- DropdownMenu
	local function reskinDropdown()
		for _, name in pairs({'DropDownList', 'L_DropDownList', 'Lib_DropDownList'}) do
			for i = 1, UIDROPDOWNMENU_MAXLEVELS do
				local menu = _G[name..i..'MenuBackdrop']
				if menu and not menu.styled then
					menu:HookScript('OnShow', TOOLTIP.ReskinTooltip)
					menu.styled = true
				end
			end
		end
	end
	hooksecurefunc('UIDropDownMenu_CreateFrames', reskinDropdown)

	-- IME
	local r, g, b = C.r, C.g, C.b
	IMECandidatesFrame.selection:SetVertexColor(r, g, b)








end)

TOOLTIP:RegisterTooltips('Blizzard_DebugTools', function()
	TOOLTIP.ReskinTooltip(FrameStackTooltip)
	TOOLTIP.ReskinTooltip(EventTraceTooltip)
	FrameStackTooltip:SetScale(UIParent:GetScale())
	EventTraceTooltip:SetParent(UIParent)
	EventTraceTooltip:SetFrameStrata('TOOLTIP')
end)


