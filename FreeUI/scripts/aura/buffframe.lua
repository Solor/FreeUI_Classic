local F, C, L = unpack(select(2, ...))
local AURA = F:GetModule('Aura')


local format, mod = string.format, mod
local BuffFrame = BuffFrame
local buffsPerRow, buffSize, margin, offset = 10, 42, 6, 8
local debuffsPerRow, debuffSize = 10, 50
local parentFrame, buffAnchor, debuffAnchor
local cfg = C.aura

local function restyleIcons(bu, isDebuff)
	if not bu or bu.styled then return end
	local name = bu:GetName()

	local iconSize = buffSize
	if isDebuff then iconSize = debuffSize end

	local border = _G[name..'Border']
	if border then border:Hide() end

	local icon = _G[name..'Icon']
	icon:SetAllPoints()
	icon:SetTexCoord(unpack(C.TexCoord))
	icon:SetDrawLayer('BACKGROUND', 1)

	local duration = _G[name..'Duration']
	duration:ClearAllPoints()
	duration:SetPoint('TOP', bu, 'BOTTOM', 2, 2)
	F.SetFS(duration, (cfg.usePixelFont and 'pixel') or {C.font.normal, 11, 'OUTLINE'}, nil, nil, (not cfg.usePixelFont))

	local count = _G[name..'Count']
	count:ClearAllPoints()
	count:SetParent(bu)
	count:SetPoint('TOPRIGHT', bu, 'TOPRIGHT', -1, -3)
	F.SetFS(count, (cfg.usePixelFont and 'pixel') or {C.font.normal, 11, 'OUTLINE'}, nil, nil, (not cfg.usePixelFont))

	bu:SetSize(iconSize, iconSize)
	bu.HL = bu:CreateTexture(nil, 'HIGHLIGHT')
	bu.HL:SetColorTexture(1, 1, 1, .25)
	bu.HL:SetAllPoints(icon)

	local bg = F.CreateBG(bu)
	local glow = F.CreateSD(bg, .5, 3, 3)
	bu.bg = bg
	bu.glow = glow

	bu.styled = true
end

local function restyleBuffs()
	local buff, previousBuff, aboveBuff, index
	local numBuffs = 0
	local slack = BuffFrame.numEnchants

	for i = 1, BUFF_ACTUAL_DISPLAY do
		buff = _G['BuffButton'..i]
		restyleIcons(buff)

		numBuffs = numBuffs + 1
		index = numBuffs + slack
		buff:ClearAllPoints()
		if index > 1 and mod(index, buffsPerRow) == 1 then
			if index == buffsPerRow + 1 then
				buff:SetPoint('TOP', TempEnchant1, 'BOTTOM', 0, -offset)
			else
				buff:SetPoint('TOP', aboveBuff, 'BOTTOM', 0, -offset)
			end
			aboveBuff = buff
		elseif numBuffs == 1 and slack == 0 then
			buff:SetPoint('TOPRIGHT', buffAnchor)
		elseif numBuffs == 1 and slack > 0 then
			buff:SetPoint('TOPRIGHT', _G['TempEnchant'..slack], 'TOPLEFT', -margin, 0)
		else
			buff:SetPoint('RIGHT', previousBuff, 'LEFT', -margin, 0)
		end
		previousBuff = buff
	end
end

local function restyleTempEnchant()
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		local bu = _G['TempEnchant'..i]
		restyleIcons(bu)
	end
end

local function restyleDebuffs(buttonName, i)
	local debuff = _G[buttonName..i]
	restyleIcons(debuff, true)

	debuff:ClearAllPoints()
	if i > 1 and mod(i, debuffsPerRow) == 1 then
		debuff:SetPoint('TOP', _G[buttonName..(i-debuffsPerRow)], 'BOTTOM', 0, -offset)
	elseif i == 1 then
		debuff:SetPoint('TOPRIGHT', debuffAnchor)
	else
		debuff:SetPoint('RIGHT', _G[buttonName..(i-1)], 'LEFT', -margin - 4, 0)
	end
end

local function updateDebuffBorder(buttonName, index, filter)
	local unit = PlayerFrame.unit
	local name, _, _, debuffType = UnitAura(unit, index, filter)
	if not name then return end
	local bu = _G[buttonName..index]
	if not (bu and bu.bg) then return end

	if filter == 'HARMFUL' then
		local color = DebuffTypeColor[debuffType or 'none']
		--bu.bg:SetVertexColor(color.r, color.g, color.b)
		if bu.glow then
			if bu.glow then
				bu.glow:SetBackdropBorderColor(color.r, color.g, color.b, 1)
			else
				bu.glow:SetBackdropBorderColor(0, 0, 0, .5)
			end
		end
	end
end

local function flashOnEnd(self)
	if self.timeLeft < 10 then
		self:SetAlpha(BuffFrame.BuffAlphaValue)
	else
		self:SetAlpha(1)
	end
end

local function formatAuraTime(seconds)
	local d, h, m, str = 0, 0, 0
	if seconds >= 86400 then
		d = seconds/86400
		seconds = seconds%86400
	end
	if seconds >= 3600 then
		h = seconds/3600
		seconds = seconds%3600
	end
	if seconds >= 60 then
		m = seconds/60
		seconds = seconds%60
	end
	if d > 0 then
		str = format('%d'..C.InfoColor..'d', d)
	elseif h > 0 then
		str = format('%d'..C.InfoColor..'h', h)
	elseif m >= 10 then
		str = format('%d'..C.InfoColor..'m', m)
	elseif m > 0 and m < 10 then
		str = format('%d:%.2d', m, seconds)
	else
		if seconds <= 5 then
			str = format('|cffff0000%.1f|r', seconds) -- red
		elseif seconds <= 10 then
			str = format('|cffffff00%.1f|r', seconds) -- yellow
		else
			str = format('%d'..C.InfoColor..'s', seconds)
		end
	end

	return str
end

function AURA:BuffFrame()
	parentFrame = CreateFrame("Frame", nil, UIParent)
	parentFrame:SetSize(buffSize, buffSize)
	buffAnchor = F.Mover(parentFrame, L['MOVER_BUFFS'], "BuffFrame", {'TOPRIGHT', UIParent, 'TOPRIGHT', -50, -50}, (buffSize + margin)*buffsPerRow, (buffSize + offset)*3)
	debuffAnchor = F.Mover(parentFrame, L['MOVER_DEBUFFS'], "DebuffFrame", {"TOPRIGHT", buffAnchor, "BOTTOMRIGHT", 0, -offset}, (debuffSize + margin)*debuffsPerRow, (debuffSize + offset)*2)
	parentFrame:ClearAllPoints()
	parentFrame:SetPoint("TOPRIGHT", buffAnchor)

	for i = 1, 3 do
		local enchant = _G['TempEnchant'..i]
		enchant:ClearAllPoints()
		if i == 1 then
			enchant:SetPoint('TOPRIGHT', buffAnchor)
		else
			enchant:SetPoint('TOPRIGHT', _G['TempEnchant'..(i-1)], 'TOPLEFT', -margin, 0)
		end
	end
	TempEnchant3:Hide()
	BuffFrame.ignoreFramePositionManager = true

	hooksecurefunc('BuffFrame_UpdateAllBuffAnchors', restyleBuffs)
	hooksecurefunc('TemporaryEnchantFrame_Update', restyleTempEnchant)
	hooksecurefunc('DebuffButton_UpdateAnchors', restyleDebuffs)
	hooksecurefunc('AuraButton_Update', updateDebuffBorder)
	hooksecurefunc('AuraButton_OnUpdate', flashOnEnd)

	hooksecurefunc('AuraButton_UpdateDuration', function(button, timeLeft)
		local duration = button.duration
		if SHOW_BUFF_DURATIONS == '1' and timeLeft then
			duration:SetText(formatAuraTime(timeLeft))
			duration:SetVertexColor(1, 1, 1)
			duration:Show()
		else
			duration:Hide()
		end
	end)
end