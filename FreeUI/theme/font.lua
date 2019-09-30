local F, C = unpack(select(2, ...))
if not C.appearance.adjustFonts then return end

local normalFont = C.font.normal
local headerFont = C.font.header
local chatFont = C.font.chat
local dmgFont = C.font.damage

_G.STANDARD_TEXT_FONT = normalFont
_G.UNIT_NAME_FONT = headerFont
_G.DAMAGE_TEXT_FONT = dmgFont

local function ReskinFont(fontObj, fontPath, fontSize, fontFlag, fontColor, fontShadow)
	fontObj:SetFont(fontPath, fontSize, fontFlag and 'OUTLINE' or '')

	if fontColor then
		fontObj:SetTextColor(fontColor.r, fontColor.g, fontColor.b)
	end

	if fontShadow then
		fontObj:SetShadowColor(0, 0, 0, 1)
		fontObj:SetShadowOffset(1, -1)
	end
end


ReskinFont(AchievementFont_Small, normalFont, 12)

ReskinFont(CoreAbilityFont, headerFont, 32)

ReskinFont(DestinyFontMed, normalFont, 14)
ReskinFont(DestinyFontHuge, headerFont, 32)
ReskinFont(DestinyFontLarge, normalFont, 18)

ReskinFont(FriendsFont_Normal, normalFont, 12)
ReskinFont(FriendsFont_Small, normalFont, 12)
ReskinFont(FriendsFont_Large, normalFont, 14)
ReskinFont(FriendsFont_UserText, normalFont, 12)

ReskinFont(GameFont_Gigantic, headerFont, 38)

ReskinFont(InvoiceFont_Small, normalFont, 10)
ReskinFont(InvoiceFont_Med, normalFont, 12)

ReskinFont(MailFont_Large, normalFont, 14)

ReskinFont(NumberFont_Small, chatFont, 11)
ReskinFont(NumberFont_GameNormal, chatFont, 12)
ReskinFont(NumberFont_Normal_Med, chatFont, 12)
ReskinFont(NumberFont_Shadow_Tiny, chatFont, 10)
ReskinFont(NumberFont_OutlineThick_Mono_Small, chatFont, 12, true)
ReskinFont(NumberFont_Outline_Med, chatFont, 12, true)
ReskinFont(NumberFont_Outline_Large, chatFont, 14, true)
ReskinFont(NumberFont_Shadow_Med, chatFont, 14, true)
ReskinFont(NumberFont_Shadow_Small, chatFont, 12)

ReskinFont(QuestFont_Shadow_Small, normalFont, 12)
ReskinFont(QuestFont_Large, normalFont, 14)
ReskinFont(QuestFont_Shadow_Huge, headerFont, 20)
ReskinFont(QuestFont_Huge, headerFont, 20)
ReskinFont(QuestFont_Super_Huge, headerFont, 22)
ReskinFont(QuestFont_Enormous, headerFont, 30)

ReskinFont(ReputationDetailFont, normalFont, 12)
ReskinFont(SpellFont_Small, normalFont, 12)

ReskinFont(SystemFont_InverseShadow_Small, normalFont, 10)
ReskinFont(SystemFont_Large, normalFont, 14)
ReskinFont(SystemFont_Huge1, normalFont, 20)
ReskinFont(SystemFont_Huge2, headerFont, 24)
ReskinFont(SystemFont_Med1, normalFont, 12)
ReskinFont(SystemFont_Med2, normalFont, 14)
ReskinFont(SystemFont_Med3, normalFont, 13)
ReskinFont(SystemFont_OutlineThick_WTF, headerFont, 32, true)
ReskinFont(SystemFont_OutlineThick_Huge2, headerFont, 22, true)
ReskinFont(SystemFont_OutlineThick_Huge4, headerFont, 26, true)
ReskinFont(SystemFont_Outline_Small, normalFont, 12, true)
ReskinFont(SystemFont_Outline, normalFont, 15, true)
ReskinFont(SystemFont_Shadow_Large, normalFont, 16)
ReskinFont(SystemFont_Shadow_Large_Outline, normalFont, 16, true)
ReskinFont(SystemFont_Shadow_Large2, normalFont, 18)
ReskinFont(SystemFont_Shadow_Med1, normalFont, 12)
ReskinFont(SystemFont_Shadow_Med1_Outline, normalFont, 12, true)
ReskinFont(SystemFont_Shadow_Med2, normalFont, 16)
ReskinFont(SystemFont_Shadow_Med3, normalFont, 14)
ReskinFont(SystemFont_Shadow_Outline_Huge2, normalFont, 22, true)
ReskinFont(SystemFont_Shadow_Huge1, normalFont, 20)
ReskinFont(SystemFont_Shadow_Huge2, normalFont, 24)
ReskinFont(SystemFont_Shadow_Huge3, normalFont, 25)
ReskinFont(SystemFont_Shadow_Small, normalFont, 12)
ReskinFont(SystemFont_Shadow_Small2, normalFont, 12)
ReskinFont(SystemFont_Small, normalFont, 12)
ReskinFont(SystemFont_Small2, normalFont, 13)
ReskinFont(SystemFont_Tiny, normalFont, 9)
ReskinFont(SystemFont_Tiny2, normalFont, 8)
ReskinFont(SystemFont_NamePlate, normalFont, 12)
ReskinFont(SystemFont_LargeNamePlate, normalFont, 12)
ReskinFont(SystemFont_NamePlateFixed, normalFont, 12)
ReskinFont(SystemFont_LargeNamePlateFixed, normalFont, 12)
ReskinFont(SystemFont_World, headerFont, 64)
ReskinFont(SystemFont_World_ThickOutline, headerFont, 64, true)
ReskinFont(SystemFont_WTF2, headerFont, 64)

ReskinFont(HelpFrameKnowledgebaseNavBarHomeButtonText, normalFont, 14)

ReskinFont(Game11Font, normalFont, 11)
ReskinFont(Game12Font, normalFont, 12)
ReskinFont(Game13Font, normalFont, 13)
ReskinFont(Game13FontShadow, normalFont, 13)
ReskinFont(Game15Font, normalFont, 15)
ReskinFont(Game16Font, normalFont, 16)
ReskinFont(Game18Font, normalFont, 18)
ReskinFont(Game20Font, normalFont, 20)
ReskinFont(Game24Font, normalFont, 24)
ReskinFont(Game27Font, normalFont, 27)
ReskinFont(Game30Font, normalFont, 30)
ReskinFont(Game32Font, normalFont, 32)
ReskinFont(Game36Font, normalFont, 36)
ReskinFont(Game42Font, normalFont, 42)
ReskinFont(Game46Font, normalFont, 46)
ReskinFont(Game48Font, normalFont, 48)
ReskinFont(Game48FontShadow, normalFont, 48)
ReskinFont(Game60Font, normalFont, 60)
ReskinFont(Game72Font, normalFont, 72)
ReskinFont(Game120Font, normalFont, 120)
ReskinFont(System_IME, normalFont, 16)
ReskinFont(Fancy12Font, normalFont, 12)
ReskinFont(Fancy14Font, normalFont, 14)
ReskinFont(Fancy16Font, normalFont, 16)
ReskinFont(Fancy18Font, normalFont, 18)
ReskinFont(Fancy20Font, normalFont, 20)
ReskinFont(Fancy22Font, normalFont, 22)
ReskinFont(Fancy24Font, normalFont, 24)
ReskinFont(Fancy27Font, normalFont, 27)
ReskinFont(Fancy30Font, normalFont, 30)
ReskinFont(Fancy32Font, normalFont, 32)
ReskinFont(Fancy48Font, normalFont, 48)

ReskinFont(SplashHeaderFont, normalFont, 24)
ReskinFont(ChatBubbleFont, normalFont, 16)
ReskinFont(GameFontNormalHuge2, normalFont, 24)
ReskinFont(SplashHeaderFont, normalFont, 24)

ReskinFont(GameTooltipHeader, normalFont, 14)
ReskinFont(Tooltip_Med, normalFont, 12)
ReskinFont(Tooltip_Small, normalFont, 12)

ReskinFont(ZoneTextFont, headerFont, 40)
ReskinFont(SubZoneTextFont, headerFont, 40)
ReskinFont(WorldMapTextFont, headerFont, 40)

ReskinFont(ErrorFont, normalFont, 14)
ReskinFont(GameFontNormalHuge, normalFont, 14)

ReskinFont(RaidWarningFrame.slot1, normalFont, 20)
ReskinFont(RaidWarningFrame.slot2, normalFont, 20)
ReskinFont(RaidBossEmoteFrame.slot1, normalFont, 20)
ReskinFont(RaidBossEmoteFrame.slot2, normalFont, 20)


-- WhoFrame LevelText
hooksecurefunc('WhoList_Update', function()
	for i = 1, WHOS_TO_DISPLAY, 1 do
		local level = _G['WhoFrameButton'..i..'Level']
		if level and not level.fontStyled then
			level:SetWidth(32)
			level:SetJustifyH('LEFT')
			level.fontStyled = true
		end
	end
end)

-- Text color
GameFontBlackMedium:SetTextColor(1, 1, 1)
CoreAbilityFont:SetTextColor(1, 1, 1)

--[[local ColorizeFonts = {
	'GameFontNormal',
	'GameFontNormal_NoShadow',
	'GameFontNormalHuge',
	'GameFontNormalSmall',
	'GameFontNormalTiny',
	'GameFontNormalTiny2',
	'GameFontNormalMed1',
	'GameFontNormalMed2',
	'GameFontNormalLarge',
	'GameFontNormalLargeOutline',
	'GameFontNormalHugeOutline2',
	'GameFontNormalOutline',
	'GameFontNormalMed3',
	'GameFontNormalSmall2',
	'GameFontNormalLarge2',
	'GameFontNormalWTF2',
	'GameFontNormalWTF2Outline',
	'GameFontNormalHuge2',
	'GameFontNormalShadowHuge2',
	'GameFontNormalHugeOutline',
	'GameFontNormalHuge3',
	'GameFontNormalHuge3Outline',
	'GameFontNormalHuge4',
	'GameFontNormalHuge4Outline',
	'IMEHighlight',
	'BossEmoteNormalHuge',
	'NumberFontNormalRightYellow',
	'NumberFontNormalYellow',
	'NumberFontNormalLargeRightYellow',
	'NumberFontNormalLargeYellow',
	'DialogButtonNormalText',
	'GameNormalNumberFont',
	'CombatTextFont',
	'CombatTextFontOutline',
	'AchievementPointsFont',
	'AchievementPointsFontSmall',
	'AchievementDateFont',
	'FocusFontSmall',
	'ArtifactAppearanceSetNormalFont',
	'Fancy22Font',
	'QuestFont_Super_Huge',
	'QuestFont_Super_Huge_Outline',
	'SplashHeaderFont',
	'QuestFont_Enormous',
	'GameFont_Gigantic',
}
for _, font in next, ColorizeFonts do
	_G[font]:SetTextColor(233/255, 197/255, 93/255)
end

NORMAL_FONT_COLOR = CreateColor(233/255, 197/255, 93/255)
NORMAL_FONT_COLOR_CODE = '|cffe9c55d'--]]