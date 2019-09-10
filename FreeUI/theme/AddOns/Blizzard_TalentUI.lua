local F, C = unpack(select(2, ...))

C.themes["Blizzard_TalentUI"] = function()
	local r, g, b = C.r, C.g, C.b

	F.ReskinPortraitFrame(TalentFrame, 20, -10, -33, 75)
	F.Reskin(TalentFrameCancelButton)
	F.ReskinScroll(TalentFrameScrollFrameScrollBar)
	for i = 1, 3 do
		local tab = _G["TalentFrameTab"..i]
		F.ReskinTab(tab)
	end
	F.StripTextures(TalentFrameScrollFrame)
	--F.CreateBDFrame(TalentFrameScrollFrame)

	TalentFrameBackgroundTopLeft:SetAlpha(0)
	TalentFrameBackgroundTopRight:SetAlpha(0)
	TalentFrameBackgroundBottomLeft:SetAlpha(0)
	TalentFrameBackgroundBottomRight:SetAlpha(0)

	for i = 1, MAX_NUM_TALENTS do
		local talent = _G['TalentFrameTalent'..i]
		local icon = _G['TalentFrameTalent'..i..'IconTexture']
		local rank = _G['TalentFrameTalent'..i..'Rank']

		if talent then
			F.StripTextures(talent)
			icon:SetTexCoord(.08, .92, .08, .92)
			F.CreateBDFrame(icon)
		end
	end
end