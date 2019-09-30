local F, C, L = unpack(select(2, ...))

local type, pairs, tonumber, wipe = type, pairs, tonumber, table.wipe
local strmatch, gmatch, strfind, format, gsub = string.match, string.gmatch, string.find, string.format, string.gsub
local min, max, abs, floor = math.min, math.max, math.abs, math.floor

local r, g, b = C.ClassColors[C.Class].r, C.ClassColors[C.Class].g, C.ClassColors[C.Class].b


-- [[ Functions ]]

-- UI scale
local function clipScale(scale)
	return tonumber(format('%.5f', scale))
end

local function GetPerfectScale()
	local _, height = GetPhysicalScreenSize()
	local scale = C.general.uiScale
	local bestScale = max(.4, min(1.15, 768 / height))
	local pixelScale = 768 / height

	if C.general.uiScaleAuto then scale = clipScale(bestScale) end

	C.Mult = (bestScale / scale) - ((bestScale - pixelScale) / scale)

	return scale
end
GetPerfectScale()

local isScaling = false
function F:SetupUIScale()
	if isScaling then return end
	isScaling = true

	local scale = GetPerfectScale()
	local parentScale = UIParent:GetScale()
	if scale ~= parentScale then
		UIParent:SetScale(scale)
	end

	C.general.uiScale = clipScale(scale)

	isScaling = false
end

function F:CreateFS(font, text, colour, shadow, anchor, x, y)
	local fs = self:CreateFontString(nil, 'OVERLAY')
	fs:SetWordWrap(false)

	if type(font) == 'table' then
		fs:SetFont(font[1], font[2], font[3])
	elseif type(font) == 'string' then
		if font == 'pixel' then
			fs:SetFont(C.font.pixel, 8, 'OUTLINEMONOCHROME')
		end
	end

	if text then
		fs:SetText(text)
	end

	if colour then
		if type(colour) == 'table' then
			fs:SetTextColor(colour[1], colour[2], colour[3])
		elseif type(colour) == 'string' then
			if colour == 'class' then
				fs:SetTextColor(C.r, C.g, C.b)
			elseif colour == 'yellow' then
				fs:SetTextColor(.9, .82, .62)
			elseif colour == 'red' then
				fs:SetTextColor(1, .15, .21)
			elseif colour == 'green' then
				fs:SetTextColor(.23, .62, .21)
			elseif colour == 'grey' then
				fs:SetTextColor(.5, .5, .5)
			end
		end
	else
		fs:SetTextColor(1, 1, 1)
	end

	if shadow then
		if type(shadow) == 'table' then
			fs:SetShadowColor(shadow[1], shadow[2], shadow[3], shadow[4])
			fs:SetShadowOffset(shadow[5], shadow[6])
		elseif type(shadow) == 'boolean' then
			fs:SetShadowColor(0, 0, 0, 1)
			fs:SetShadowOffset(1, -1)
		else
			fs:SetShadowColor(0, 0, 0, 0)
		end
	end

	if anchor and x and y then
		fs:SetPoint(anchor, x, y)
	else
		fs:SetPoint('CENTER', 1, 0)
	end

	return fs
end

function F.SetFS(object, font, text, colour, shadow)
	if type(font) == 'table' then
		object:SetFont(font[1], font[2], font[3])
	elseif type(font) == 'string' then
		if font == 'pixel' then
			object:SetFont(C.font.pixel, 8, 'OUTLINEMONOCHROME')
		elseif font == 'standard' then
			object:SetFont(C.font.normal, 12, 'OUTLINE')
		end
	end

	if text then
		object:SetText(text)
	end

	if colour then
		if type(colour) == 'table' then
			object:SetTextColor(colour[1], colour[2], colour[3])
		elseif type(colour) == 'string' then
			if colour == 'class' then
				object:SetTextColor(C.r, C.g, C.b)
			elseif colour == 'yellow' then
				object:SetTextColor(.9, .8, .6)
			elseif colour == 'red' then
				object:SetTextColor(1, .2, .2)
			elseif colour == 'green' then
				object:SetTextColor(.2, .6, .2)
			elseif colour == 'grey' then
				object:SetTextColor(.5, .5, .5)
			end
		end
	end

	if shadow then
		if type(shadow) == 'table' then
			object:SetShadowColor(shadow[1], shadow[2], shadow[3], shadow[4])
			object:SetShadowOffset(shadow[5], shadow[6])
		elseif type(shadow) == 'boolean' then
			object:SetShadowColor(0, 0, 0, 1)
			object:SetShadowOffset(1, -1)
		else
			object:SetShadowColor(0, 0, 0, 0)
		end
	end
end

function F:CreateTex()
	if self.Tex then return end

	local frame = self
	if self:GetObjectType() == 'Texture' then frame = self:GetParent() end

	self.Tex = frame:CreateTexture(nil, 'BACKGROUND', nil, 1)
	self.Tex:SetAllPoints(self)
	self.Tex:SetTexture(C.media.bgTex, true, true)
	self.Tex:SetHorizTile(true)
	self.Tex:SetVertTile(true)
	self.Tex:SetBlendMode('ADD')
end

function F:CreateSD(a, m, s)
	if not C.appearance.addShadowBorder then return end
	if self.Shadow then return end

	local frame = self
	if self:GetObjectType() == 'Texture' then frame = self:GetParent() end
	local lvl = frame:GetFrameLevel()
	if not m then m, s = 3, 3 end

	self.Shadow = CreateFrame('Frame', nil, frame)
	self.Shadow:SetPoint('TOPLEFT', self, -m*C.Mult, m*C.Mult)
	self.Shadow:SetPoint('BOTTOMRIGHT', self, m*C.Mult, -m*C.Mult)
	self.Shadow:SetBackdrop({edgeFile = C.media.glowTex, edgeSize = s*C.Mult})
	self.Shadow:SetBackdropBorderColor(0, 0, 0, a or .35)
	self.Shadow:SetFrameLevel(lvl == 0 and 0 or lvl - 1)

	return self.Shadow
end

function F:CreateBD(a)
	self:SetBackdrop({
		bgFile = C.media.bdTex, edgeFile = C.media.bdTex, edgeSize = C.Mult,
	})
	self:SetBackdropColor(C.appearance.backdropColour[1], C.appearance.backdropColour[2], C.appearance.backdropColour[3], a or C.appearance.backdropAlpha)
	self:SetBackdropBorderColor(C.appearance.borderColour[1], C.appearance.borderColour[2], C.appearance.borderColour[3], C.appearance.borderAlpha)

	F.CreateTex(self)
end

function F:CreateBG(offset)
	local f = self
	if self:GetObjectType() == 'Texture' then f = self:GetParent() end
	offset = offset or C.Mult

	local bg = f:CreateTexture(nil, 'BACKGROUND')
	bg:SetPoint('TOPLEFT', self, -offset, offset)
	bg:SetPoint('BOTTOMRIGHT', self, offset, -offset)
	bg:SetTexture(C.media.bdTex)
	bg:SetVertexColor(0, 0, 0, 1)

	return bg
end

function F:CreateBDFrame(a)
	local frame = self
	if self:GetObjectType() == 'Texture' then frame = self:GetParent() end
	local lvl = frame:GetFrameLevel()

	local bg = CreateFrame('Frame', nil, frame)
	bg:SetPoint('TOPLEFT', self, -C.Mult, C.Mult)
	bg:SetPoint('BOTTOMRIGHT', self, C.Mult, -C.Mult)
	bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)
	F.CreateBD(bg, a or C.appearance.backdropAlpha)

	return bg
end

function F:CreateGradient()
	local tex = self:CreateTexture(nil, 'BORDER')
	tex:SetPoint('TOPLEFT', C.Mult, -C.Mult)
	tex:SetPoint('BOTTOMRIGHT', -C.Mult, C.Mult)
	tex:SetTexture(C.appearance.gradient and C.media.gradient or C.media.bdTex)

	if C.appearance.gradient then
		tex:SetVertexColor(unpack(C.appearance.buttonGradientColour))
	else
		tex:SetVertexColor(unpack(C.appearance.buttonSolidColour))
	end

	return tex
end

local function CreatePulse(frame)
	local speed = .05
	local mult = 1
	local alpha = 1
	local last = 0
	frame:SetScript('OnUpdate', function(self, elapsed)
		last = last + elapsed
		if last > speed then
			last = 0
			self:SetAlpha(alpha)
		end
		alpha = alpha - elapsed*mult
		if alpha < 0 and mult > 0 then
			mult = mult*-1
			alpha = 0
		elseif alpha > 1 and mult < 0 then
			mult = mult*-1
		end
	end)
end

local function StartGlow(f)
	if not f:IsEnabled() then return end

	f:SetBackdropBorderColor(r, g, b, 1)
	f.glow:SetAlpha(1)
	CreatePulse(f.glow)
end

local function StopGlow(f)
	f:SetBackdropBorderColor(C.appearance.borderColour[1], C.appearance.borderColour[2], C.appearance.borderColour[3], C.appearance.borderAlpha)

	f.glow:SetScript('OnUpdate', nil)
	f.glow:SetAlpha(0)
end

function F.Reskin(f, noGlow)
	if f.SetNormalTexture then f:SetNormalTexture('') end
	if f.SetHighlightTexture then f:SetHighlightTexture('') end
	if f.SetPushedTexture then f:SetPushedTexture('') end
	if f.SetDisabledTexture then f:SetDisabledTexture('') end

	if f.Left then f.Left:SetAlpha(0) end
	if f.Middle then f.Middle:SetAlpha(0) end
	if f.Right then f.Right:SetAlpha(0) end
	if f.LeftSeparator then f.LeftSeparator:SetAlpha(0) end
	if f.RightSeparator then f.RightSeparator:SetAlpha(0) end
	if f.TopLeft then f.TopLeft:SetAlpha(0) end
	if f.TopMiddle then f.TopMiddle:SetAlpha(0) end
	if f.TopRight then f.TopRight:SetAlpha(0) end
	if f.MiddleLeft then f.MiddleLeft:SetAlpha(0) end
	if f.MiddleMiddle then f.MiddleMiddle:SetAlpha(0) end
	if f.MiddleRight then f.MiddleRight:SetAlpha(0) end
	if f.BottomLeft then f.BottomLeft:SetAlpha(0) end
	if f.BottomMiddle then f.BottomMiddle:SetAlpha(0) end
	if f.BottomRight then f.BottomRight:SetAlpha(0) end

	F.CreateBD(f, .3)

	f.bgTex = F.CreateGradient(f)
	
	if not noGlow then
		f.glow = CreateFrame('Frame', nil, f)
		f.glow:SetBackdrop({
			edgeFile = C.media.glowTex,
			edgeSize = 5,
		})
		f.glow:SetPoint('TOPLEFT', -6, 6)
		f.glow:SetPoint('BOTTOMRIGHT', 6, -6)
		f.glow:SetBackdropBorderColor(r, g, b)
		f.glow:SetAlpha(0)

		f:HookScript('OnEnter', StartGlow)
		f:HookScript('OnLeave', StopGlow)
	end
end

function F:ReskinTab()
	self:DisableDrawLayer('BACKGROUND')
	local bg = F.CreateBDFrame(self)
	bg:SetPoint('TOPLEFT', 8, -3)
	bg:SetPoint('BOTTOMRIGHT', -8, 0)
	
	self:SetHighlightTexture(C.media.bdTex)
	local hl = self:GetHighlightTexture()
	hl:SetAllPoints(bg)
	hl:SetVertexColor(r, g, b, .25)

	return bg
end

local function textureOnEnter(self)
	if self:IsEnabled() then
		if self.pixels then
			for _, pixel in pairs(self.pixels) do
				pixel:SetVertexColor(r, g, b)
			end
		else
			--self.bgTex:SetVertexColor(C.r, C.g, C.b)
		end
	end
end
F.colourArrow = textureOnEnter

local function textureOnLeave(self)
	if self.pixels then
		for _, pixel in pairs(self.pixels) do
			pixel:SetVertexColor(1, 1, 1)
		end
	else
		--self.bgTex:SetVertexColor(0, 0, 0)
	end
end
F.clearArrow = textureOnLeave

local function scrollOnEnter(self)
	local bu = (self.ThumbTexture or self.thumbTexture) or _G[self:GetName()..'ThumbTexture']
	if not bu then return end
	bu.bg:SetBackdropColor(r, g, b, .25)
	bu.bg:SetBackdropBorderColor(r, g, b)
end

local function scrollOnLeave(self)
	local bu = (self.ThumbTexture or self.thumbTexture) or _G[self:GetName()..'ThumbTexture']
	if not bu then return end
	bu.bg:SetBackdropColor(0, 0, 0, 0)
	bu.bg:SetBackdropBorderColor(0, 0, 0)
end

function F:ReskinScroll()
	local frame = self:GetName()
	F.StripTextures(self:GetParent())
	F.StripTextures(self)

	local bu = (self.ThumbTexture or self.thumbTexture) or frame and _G[frame..'ThumbTexture']
	bu:SetAlpha(0)
	bu:SetWidth(17)

	bu.bg = CreateFrame('Frame', nil, self)
	bu.bg:SetPoint('TOPLEFT', bu, 0, -2)
	bu.bg:SetPoint('BOTTOMRIGHT', bu, 0, 4)
	F.CreateBD(bu.bg, .8)

	local tex = F.CreateGradient(self)
	tex:SetPoint('TOPLEFT', bu.bg, C.Mult, -C.Mult)
	tex:SetPoint('BOTTOMRIGHT', bu.bg, -C.Mult, C.Mult)

	local up, down = self:GetChildren()
	up:SetWidth(17)
	down:SetWidth(17)

	F.Reskin(up, true)
	F.Reskin(down, true)

	up:SetDisabledTexture(C.media.bdTex)
	local dis1 = up:GetDisabledTexture()
	dis1:SetVertexColor(0, 0, 0, .4)
	dis1:SetDrawLayer('OVERLAY')

	down:SetDisabledTexture(C.media.bdTex)
	local dis2 = down:GetDisabledTexture()
	dis2:SetVertexColor(0, 0, 0, .4)
	dis2:SetDrawLayer('OVERLAY')

	local uptex = up:CreateTexture(nil, 'ARTWORK')
	uptex:SetTexture(C.media.arrowUp)
	uptex:SetSize(8, 8)
	uptex:SetPoint('CENTER')
	uptex:SetVertexColor(1, 1, 1)
	up.bgTex = uptex

	local downtex = down:CreateTexture(nil, 'ARTWORK')
	downtex:SetTexture(C.media.arrowDown)
	downtex:SetSize(8, 8)
	downtex:SetPoint('CENTER')
	downtex:SetVertexColor(1, 1, 1)
	down.bgTex = downtex

	up:HookScript('OnEnter', textureOnEnter)
	up:HookScript('OnLeave', textureOnLeave)
	down:HookScript('OnEnter', textureOnEnter)
	down:HookScript('OnLeave', textureOnLeave)
end

function F:ReskinDropDown()
	local frame = self:GetName()

	local left = self.Left or _G[frame..'Left']
	local middle = self.Middle or _G[frame..'Middle']
	local right = self.Right or _G[frame..'Right']

	if left then left:SetAlpha(0) end
	if middle then middle:SetAlpha(0) end
	if right then right:SetAlpha(0) end

	local down = self.Button or _G[frame..'Button']

	down:SetSize(20, 20)
	down:ClearAllPoints()
	down:SetPoint('RIGHT', -18, 2)

	F.Reskin(down, true)

	down:SetDisabledTexture(C.media.bdTex)
	local dis = down:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .4)
	dis:SetDrawLayer('OVERLAY')
	dis:SetAllPoints()

	local tex = down:CreateTexture(nil, 'ARTWORK')
	tex:SetTexture(C.media.arrowDown)
	tex:SetSize(8, 8)
	tex:SetPoint('CENTER')
	tex:SetVertexColor(1, 1, 1)
	down.bgtex = tex

	down:HookScript('OnEnter', textureOnEnter)
	down:HookScript('OnLeave', textureOnLeave)

	local bg = F.CreateBDFrame(self, 0)
	bg:SetPoint('TOPLEFT', 16, -4)
	bg:SetPoint('BOTTOMRIGHT', -18, 8)

	local gradient = F.CreateGradient(self)
	gradient:SetPoint('TOPLEFT', bg, C.Mult, -C.Mult)
	gradient:SetPoint('BOTTOMRIGHT', bg, -C.Mult, C.Mult)
end

function F:ReskinClose(a1, p, a2, x, y)
	self:SetSize(17*C.Mult, 17*C.Mult)

	if not a1 then
		self:SetPoint('TOPRIGHT', -6, -6)
	else
		self:ClearAllPoints()
		self:SetPoint(a1, p, a2, x, y)
	end

	F.StripTextures(self)
	F.CreateBD(self, 0)
	F.CreateGradient(self)

	self:SetDisabledTexture(C.media.bdTex)
	local dis = self:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .4)
	dis:SetDrawLayer('OVERLAY')
	dis:SetAllPoints()

	self.pixels = {}
	for i = 1, 2 do
		local tex = self:CreateTexture()
		tex:SetColorTexture(1, 1, 1)
		tex:SetSize(11, 2)
		tex:SetPoint('CENTER')
		tex:SetRotation(math.rad((i-1/2)*90))
		tinsert(self.pixels, tex)
	end

	self:HookScript('OnEnter', textureOnEnter)
	self:HookScript('OnLeave', textureOnLeave)
end

function F:ReskinInput(height, width)
	local frame = self:GetName()

	local left = self.Left or _G[frame..'Left']
	local middle = self.Middle or _G[frame..'Middle'] or _G[frame..'Mid']
	local right = self.Right or _G[frame..'Right']

	left:Hide()
	middle:Hide()
	right:Hide()

	local bd = CreateFrame('Frame', nil, self)
	bd:SetPoint('TOPLEFT', -2, 0)
	bd:SetPoint('BOTTOMRIGHT')
	bd:SetFrameLevel(self:GetFrameLevel() - 1)
	F.CreateBD(bd)

	local gradient = F.CreateGradient(self)
	gradient:SetPoint('TOPLEFT', bd, C.Mult, -C.Mult)
	gradient:SetPoint('BOTTOMRIGHT', bd, -C.Mult, C.Mult)

	if height then self:SetHeight(height) end
	if width then self:SetWidth(width) end
end

function F:ReskinArrow(direction)
	self:SetSize(18, 18)
	F.Reskin(self, true)

	self:SetDisabledTexture(C.media.bdTex)
	local dis = self:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .3)
	dis:SetDrawLayer('OVERLAY')

	local tex = self:CreateTexture(nil, 'ARTWORK')
	tex:SetTexture(C.AssetsPath..'arrow-'..direction..'-active')
	tex:SetSize(8, 8)
	tex:SetPoint('CENTER')
	self.bgtex = tex

	self:HookScript('OnEnter', textureOnEnter)
	self:HookScript('OnLeave', textureOnLeave)
end

local function checkOnEnter(self)
	self.glow:SetBackdropBorderColor(r, g, b, .35)
	self.bg:SetBackdropBorderColor(r, g, b)
end

local function checkOnLeave(self)
	self.glow:SetBackdropBorderColor(0, 0, 0, .35)
	self.bg:SetBackdropBorderColor(0, 0, 0, 1)
end

function F:ReskinCheck(default)
	self:SetNormalTexture('')
	self:SetPushedTexture('')
	self:SetHighlightTexture(C.media.bdTex)
	
	local bd = CreateFrame('Frame', nil, self)
	bd:SetPoint('TOPLEFT', 7, -7)
	bd:SetPoint('BOTTOMRIGHT', -7, 7)
	bd:SetFrameLevel(self:GetFrameLevel() - 1)
	self.bg = F.CreateBDFrame(bd)

	self.glow = F.CreateSD(self.bg)

	local hl = self:GetHighlightTexture()
	hl:SetPoint('TOPLEFT', 7, -7)
	hl:SetPoint('BOTTOMRIGHT', -7, 7)
	hl:SetVertexColor(r, g, b, .25)

	self:HookScript('OnEnter', checkOnEnter)
	self:HookScript('OnLeave', checkOnLeave)

	local tex = F.CreateGradient(self)
	tex:SetPoint('TOPLEFT', 7, -7)
	tex:SetPoint('BOTTOMRIGHT', -7, 7)

	if not default then
		self:SetCheckedTexture(C.media.bdTex)

		if self.SetCheckedTexture then
			local ch = self:GetCheckedTexture()
			ch:SetPoint('TOPLEFT', 8, -8)
			ch:SetPoint('BOTTOMRIGHT', -8, 8)
			ch:SetDesaturated(true)
			ch:SetVertexColor(r, g, b)

		end

		self:SetDisabledCheckedTexture(C.media.bdTex)

		if self.SetDisabledCheckedTexture then
			local dis = self:GetDisabledCheckedTexture()
			dis:SetPoint('TOPLEFT', 8, -8)
			dis:SetPoint('BOTTOMRIGHT', -8, 8)
			dis:SetVertexColor(.5, .5, .5, .75)

		end
	end
end

local function colourRadio(self)
	self.bd:SetBackdropBorderColor(r, g, b)
end

local function clearRadio(self)
	self.bd:SetBackdropBorderColor(0, 0, 0)
end

function F:ReskinRadio()
	self:SetNormalTexture('')
	self:SetHighlightTexture('')
	self:SetCheckedTexture(C.media.bdTex)

	local ch = self:GetCheckedTexture()
	ch:SetPoint('TOPLEFT', 4, -4)
	ch:SetPoint('BOTTOMRIGHT', -4, 4)
	ch:SetVertexColor(r, g, b, .6)

	local bd = CreateFrame('Frame', nil, self)
	bd:SetPoint('TOPLEFT', 3, -3)
	bd:SetPoint('BOTTOMRIGHT', -3, 3)
	bd:SetFrameLevel(self:GetFrameLevel() - 1)
	F.CreateBD(bd)
	self.bd = bd

	local tex = F.CreateGradient(self)
	tex:SetPoint('TOPLEFT', 4, -4)
	tex:SetPoint('BOTTOMRIGHT', -4, 4)

	self:HookScript('OnEnter', colourRadio)
	self:HookScript('OnLeave', clearRadio)
end

function F:ReskinSlider(verticle)
	self:SetBackdrop(nil)
	self.SetBackdrop = F.Dummy

	local bd = CreateFrame('Frame', nil, self)
	bd:SetPoint('TOPLEFT', 14, -2)
	bd:SetPoint('BOTTOMRIGHT', -15, 3)
	bd:SetFrameStrata('BACKGROUND')
	bd:SetFrameLevel(self:GetFrameLevel() - 1)
	F.CreateBD(bd)

	F.CreateGradient(bd)

	for i = 1, self:GetNumRegions() do
		local region = select(i, self:GetRegions())
		if region:GetObjectType() == 'Texture' then
			region:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark')
			region:SetBlendMode('ADD')

			if verticle then region:SetRotation(math.rad(90)) end
			return
		end
	end
end

local function expandOnEnter(self)
	if self:IsEnabled() then
		self.bg:SetBackdropColor(r, g, b, .3)
	end
end

local function expandOnLeave(self)
	self.bg:SetBackdropColor(0, 0, 0, .3)
end

local function SetupTexture(self, texture)
	if self.settingTexture then return end
	self.settingTexture = true
	self:SetNormalTexture('')

	if texture and texture ~= '' then
		if texture:find('Plus') then
			self.expTex:SetTexCoord(0, 0.4375, 0, 0.4375)
		elseif texture:find('Minus') then
			self.expTex:SetTexCoord(0.5625, 1, 0, 0.4375)
		end
		self.bg:Show()
	else
		self.bg:Hide()
	end
	self.settingTexture = nil
end

function F:ReskinExpandOrCollapse()
	self:SetHighlightTexture('')
	self:SetPushedTexture('')

	local bg = F.CreateBDFrame(self, .3)
	bg:ClearAllPoints()
	bg:SetSize(13, 13)
	bg:SetPoint('TOPLEFT', self:GetNormalTexture())
	F.CreateGradient(bg)
	self.bg = bg

	self.expTex = bg:CreateTexture(nil, 'OVERLAY')
	self.expTex:SetSize(7, 7)
	self.expTex:SetPoint('CENTER')
	self.expTex:SetTexture('Interface\\Buttons\\UI-PlusMinus-Buttons')

	self:HookScript('OnEnter', expandOnEnter)
	self:HookScript('OnLeave', expandOnLeave)
	hooksecurefunc(self, 'SetNormalTexture', SetupTexture)
end

function F:SetBD(x, y, x2, y2)
	local bg = F.CreateBDFrame(self)
	if x then
		bg:SetPoint('TOPLEFT', x, y)
		bg:SetPoint('BOTTOMRIGHT', x2, y2)
	end
	F.CreateSD(bg)

	return bg
end

function F:ReskinPortraitFrame(x, y, x2, y2)
	F.StripTextures(self)
	local bg = F.SetBD(self, x, y, x2, y2)
	local frameName = self.GetName and self:GetName()
	local portrait = self.portrait or _G[frameName..'Portrait']
	if portrait then portrait:SetAlpha(0) end
	local closeButton = self.CloseButton or _G[frameName..'CloseButton']
	if closeButton then
		F.ReskinClose(closeButton)
		closeButton:ClearAllPoints()
		closeButton:SetPoint('TOPRIGHT', bg, -5, -5)
	end

	return bg
end

function F:ReskinColourSwatch()
	local name = self:GetName()

	self:SetNormalTexture(C.media.bdTex)
	local nt = self:GetNormalTexture()
	nt:SetPoint('TOPLEFT', 3, -3)
	nt:SetPoint('BOTTOMRIGHT', -3, 3)

	local bg = _G[name..'SwatchBg']
	bg:SetColorTexture(0, 0, 0)
	bg:SetPoint('TOPLEFT', 2, -2)
	bg:SetPoint('BOTTOMRIGHT', -2, 2)
end

function F:ReskinFilterButton()
	self.TopLeft:Hide()
	self.TopRight:Hide()
	self.BottomLeft:Hide()
	self.BottomRight:Hide()
	self.TopMiddle:Hide()
	self.MiddleLeft:Hide()
	self.MiddleRight:Hide()
	self.BottomMiddle:Hide()
	self.MiddleMiddle:Hide()

	F.Reskin(self)
	self.Text:SetPoint('CENTER')
	self.Icon:SetTexture(C.media.arrowRight)
	self.Icon:SetPoint('RIGHT', self, 'RIGHT', -5, 0)
	self.Icon:SetSize(8, 8)
end

function F:ReskinNavBar()
	if self.navBarStyled then return end

	local homeButton = self.homeButton
	local overflowButton = self.overflowButton

	self:GetRegions():Hide()
	self:DisableDrawLayer('BORDER')
	self.overlay:Hide()
	homeButton:GetRegions():Hide()
	F.Reskin(homeButton)
	F.Reskin(overflowButton, true)

	local tex = overflowButton:CreateTexture(nil, 'ARTWORK')
	tex:SetTexture(C.media.arrowLeft)
	tex:SetSize(8, 8)
	tex:SetPoint('CENTER')
	overflowButton.bgTex = tex

	overflowButton:HookScript('OnEnter', textureOnEnter)
	overflowButton:HookScript('OnLeave', textureOnLeave)

	self.navBarStyled = true
end

function F:ReskinIcon()
	self:SetTexCoord(.08, .92, .08, .92)
	return F.CreateBG(self)
end

function F:ReskinMinMax()
	for _, name in next, {'MaximizeButton', 'MinimizeButton'} do
		local button = self[name]
		if button then
			button:SetSize(17, 17)
			button:ClearAllPoints()
			button:SetPoint('CENTER', -3, 0)
			F.Reskin(button)

			button.pixels = {}

			local tex = button:CreateTexture()
			tex:SetColorTexture(1, 1, 1)
			tex:SetSize(11, 2)
			tex:SetPoint('CENTER')
			tex:SetRotation(math.rad(45))
			tinsert(button.pixels, tex)

			local hline = button:CreateTexture()
			hline:SetColorTexture(1, 1, 1)
			hline:SetSize(7, 2)
			tinsert(button.pixels, hline)
			local vline = button:CreateTexture()
			vline:SetColorTexture(1, 1, 1)
			vline:SetSize(2, 7)
			tinsert(button.pixels, vline)

			if name == 'MaximizeButton' then
				hline:SetPoint('TOPRIGHT', -4, -4)
				vline:SetPoint('TOPRIGHT', -4, -4)
			else
				hline:SetPoint('BOTTOMLEFT', 4, 4)
				vline:SetPoint('BOTTOMLEFT', 4, 4)
			end

			button:SetScript('OnEnter', textureOnEnter)
			button:SetScript('OnLeave', textureOnLeave)
		end
	end
end

function F:CreateButton(width, height, text, fontSize)
	local bu = CreateFrame('Button', nil, self)
	bu:SetSize(width, height)
	F.CreateBD(bu, .3)
	if type(text) == 'boolean' then
		F.PixelIcon(bu, fontSize, true)
	else
		F.CreateBC(bu)
		bu.text = F.CreateFS(bu, {C.font.normal, fontSize or 12}, text, nil, nil, true)
	end

	return bu
end

function F:StyleSearchButton()
	F.StripTextures(self)
	if self.icon then
		F.ReskinIcon(self.icon)
	end
	F.CreateBD(self, .25)

	self:SetHighlightTexture(C.media.bdTex)
	local hl = self:GetHighlightTexture()
	hl:SetVertexColor(C.r, C.g, C.b, .25)
	hl:SetPoint('TOPLEFT', C.Mult, -C.Mult)
	hl:SetPoint('BOTTOMRIGHT', -C.Mult, C.Mult)
end

-- GameTooltip
function F:HideTooltip()
	GameTooltip:Hide()
end

local function tooltipOnEnter(self)
	GameTooltip:SetOwner(self, self.anchor)
	GameTooltip:ClearLines()
	if self.title then
		GameTooltip:AddLine(self.title)
	end
	if tonumber(self.text) then
		GameTooltip:SetSpellByID(self.text)
	elseif self.text then
		local r, g, b = 1, 1, 1
		if self.color == 'class' then
			r, g, b = C.r, C.g, C.b
		elseif self.color == 'system' then
			r, g, b = 1, .8, 0
		elseif self.color == 'info' then
			r, g, b = .6, .8, 1
		end
		GameTooltip:AddLine(self.text, r, g, b, 1)
	end
	GameTooltip:Show()
end

function F:AddTooltip(anchor, text, color)
	self.anchor = anchor
	self.text = text
	self.color = color
	self:SetScript('OnEnter', tooltipOnEnter)
	self:SetScript('OnLeave', F.HideTooltip)
end

-- Movable Frame
function F:CreateMF(parent, saved)
	local frame = parent or self
	frame:SetMovable(true)
	frame:SetUserPlaced(true)
	frame:SetClampedToScreen(true)

	self:EnableMouse(true)
	self:RegisterForDrag('LeftButton')
	self:SetScript('OnDragStart', function() frame:StartMoving() end)
	self:SetScript('OnDragStop', function()
		frame:StopMovingOrSizing()
		if not saved then return end
		local orig, _, tar, x, y = frame:GetPoint()
		FreeUIConfig['tempAnchor'][frame:GetName()] = {orig, 'UIParent', tar, x, y}
	end)
end

function F:RestoreMF()
	local name = self:GetName()
	if name and FreeUIConfig['tempAnchor'][name] then
		self:ClearAllPoints()
		self:SetPoint(unpack(FreeUIConfig['tempAnchor'][name]))
	end
end

-- Icon Style
function F:PixelIcon(texture, highlight)
	F.CreateBD(self)
	self.Icon = self:CreateTexture(nil, 'ARTWORK')
	self.Icon:SetPoint('TOPLEFT', C.Mult, -C.Mult)
	self.Icon:SetPoint('BOTTOMRIGHT', -C.Mult, C.Mult)
	self.Icon:SetTexCoord(unpack(C.TexCoord))
	if texture then
		local atlas = strmatch(texture, 'Atlas:(.+)$')
		if atlas then
			self.Icon:SetAtlas(atlas)
		else
			self.Icon:SetTexture(texture)
		end
	end
	if highlight and type(highlight) == 'boolean' then
		self:EnableMouse(true)
		self.HL = self:CreateTexture(nil, 'HIGHLIGHT')
		self.HL:SetColorTexture(1, 1, 1, .25)
		self.HL:SetPoint('TOPLEFT', C.Mult, -C.Mult)
		self.HL:SetPoint('BOTTOMRIGHT', -C.Mult, C.Mult)
	end
end

-- Statusbar
function F:CreateSB(spark, r, g, b)
	self:SetStatusBarTexture(C.media.sbTex)
	if r and g and b then
		self:SetStatusBarColor(r, g, b)
	else
		self:SetStatusBarColor(C.r, C.g, C.b)
	end
	F.CreateSD(self)
	F.CreateBDFrame(self)
	--self.BG = self:CreateTexture(nil, 'BACKGROUND')
	--self.BG:SetAllPoints()
	--self.BG:SetTexture(C.media.bdTex)
	--self.BG:SetVertexColor(0, 0, 0, .5)
	--F.CreateTex(self.BG)
	if spark then
		self.Spark = self:CreateTexture(nil, 'OVERLAY')
		self.Spark:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark')
		self.Spark:SetBlendMode('ADD')
		self.Spark:SetAlpha(.8)
		self.Spark:SetPoint('TOPLEFT', self:GetStatusBarTexture(), 'TOPRIGHT', -10, 10)
		self.Spark:SetPoint('BOTTOMRIGHT', self:GetStatusBarTexture(), 'BOTTOMRIGHT', 10, -10)
	end
end

-- Gradient Frame
function F:CreateGF(w, h, o, r, g, b, a1, a2)
	self:SetSize(w, h)
	self:SetFrameStrata('BACKGROUND')
	local gf = self:CreateTexture(nil, 'BACKGROUND')
	gf:SetAllPoints()
	gf:SetTexture(C.media.sbTex)
	gf:SetGradientAlpha(o, r, g, b, a1, r, g, b, a2)
end

-- Numberize
function F.Numb(n)
	if C.general.numberFormat == 1 then
		if n >= 1e12 then
			return ('%.2ft'):format(n / 1e12)
		elseif n >= 1e9 then
			return ('%.2fb'):format(n / 1e9)
		elseif n >= 1e6 then
			return ('%.2fm'):format(n / 1e6)
		elseif n >= 1e3 then
			return ('%.2fk'):format(n / 1e3)
		else
			return ('%.0f'):format(n)
		end
	elseif C.general.numberFormat == 2 then
		if n >= 1e12 then
			return format('%.2f'..L['MISC_NUMBER_CAP_3'], n / 1e12)
		elseif n >= 1e8 then
			return format('%.2f'..L['MISC_NUMBER_CAP_2'], n / 1e8)
		elseif n >= 1e4 then
			return format('%.2f'..L['MISC_NUMBER_CAP_1'], n / 1e4)
		else
			return format('%.0f', n)
		end
	end
end

function F.Round(x)
	return floor(x + .5)
end

-- Color code
function F.HexRGB(r, g, b)
	if r then
		if type(r) == 'table' then
			if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
		end
		return ('|cff%02x%02x%02x'):format(r*255, g*255, b*255)
	end
end

function F.ClassColor(class)
	local color = C.ClassColors[class]
	if not color then return 1, 1, 1 end
	return color.r, color.g, color.b
end

function F.UnitColor(unit)
	local r, g, b = 1, 1, 1
	if UnitIsPlayer(unit) then
		local class = select(2, UnitClass(unit))
		if class then
			r, g, b = F.ClassColor(class)
		end
	elseif UnitIsTapDenied(unit) then
		r, g, b = .6, .6, .6
	else
		local reaction = UnitReaction(unit, 'player')
		if reaction then
			local color = FACTION_BAR_COLORS[reaction]
			r, g, b = color.r, color.g, color.b
		end
	end
	return r, g, b
end

-- Disable function
F.HiddenFrame = CreateFrame('Frame')
F.HiddenFrame:Hide()

function F:HideObject()
	if self.UnregisterAllEvents then
		self:UnregisterAllEvents()
		self:SetParent(F.HiddenFrame)
	else
		self.Show = self.Hide
	end
	self:Hide()
end

local BlizzTextures = {
	'Inset',
	'inset',
	'InsetFrame',
	'LeftInset',
	'RightInset',
	'NineSlice',
	'BorderFrame',
	'bottomInset',
	'BottomInset',
	'bgLeft',
	'bgRight',
	'FilligreeOverlay',
	'Border',
	'BG',
}

function F:StripTextures(kill)
	local frameName = self.GetName and self:GetName()
	for _, texture in pairs(BlizzTextures) do
		local blizzFrame = self[texture] or frameName and _G[frameName..texture]
		if blizzFrame then
			F.StripTextures(blizzFrame, kill)
		end
	end

	if self.GetNumRegions then
		for i = 1, self:GetNumRegions() do
			local region = select(i, self:GetRegions())
			if region and region.IsObjectType and region:IsObjectType('Texture') then
				if kill and type(kill) == 'boolean' then
					F.HideObject(region)
				elseif tonumber(kill) then
					if kill == 0 then
						region:SetAlpha(0)
					elseif i ~= kill then
						region:SetTexture('')
					end
				else
					region:SetTexture('')
				end
			end
		end
	end
end

function F:Dummy()
	return
end

function F:HideOption()
	self:SetAlpha(0)
	self:SetScale(.0001)
end

-- Smoothy
local smoothing = {}
local smoother = CreateFrame('Frame')
smoother:SetScript('OnUpdate', function()
	local limit = 30/GetFramerate()
	for bar, value in pairs(smoothing) do
		local cur = bar:GetValue()
		local new = cur + math.min((value-cur)/8, math.max(value-cur, limit))
		if new ~= new then
			new = value
		end
		bar:SetValue_(new)
		if cur == value or math.abs(new - value) < 1 then
			smoothing[bar] = nil
			bar:SetValue_(value)
		end
	end
end)

local function SetSmoothValue(self, value)
	if value ~= self:GetValue() or value == 0 then
		smoothing[self] = value
	else
		smoothing[self] = nil
	end
end

function F:SmoothBar()
	if not self.SetValue_ then
		self.SetValue_ = self.SetValue
		self.SetValue = SetSmoothValue
	end
end

-- Timer Format
local day, hour, minute = 86400, 3600, 60
function F.FormatTime(s)
	if s >= day then
		return format('|cffbebfb3%d|r', s/day), s % day -- grey
	elseif s >= hour then
		return format('|cffffffff%d|r', s/hour), s % hour -- white
	elseif s >= minute then
		return format('|cff67acdb%d|r', s/minute), s % minute -- blue
	elseif s < 5 then
		if C.general.cooldown_decimal then
			return format('|cffc50046%.1f|r', s), s - format('%.1f', s)
		else
			return format('|cffc50046%d|r', s + .5), s - floor(s)
		end
	elseif s < 60 then
		return format('|cffc5b879%d|r', s), s - floor(s) -- yellow
	else
		return format('|cff996ec3%d|r', s), s - floor(s)
	end
end

function F.FormatTimeRaw(s)
	if s >= day then
		return format('%dd', s/day)
	elseif s >= hour then
		return format('%dh', s/hour)
	elseif s >= minute then
		return format('%dm', s/minute)
	elseif s >= 3 then
		return floor(s)
	else
		return format('%d', s)
	end
end

function F:CooldownOnUpdate(elapsed, raw)
	local formatTime = raw and F.FormatTimeRaw or F.FormatTime
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.1 then
		local timeLeft = self.expiration - GetTime()
		if timeLeft > 0 then
			local text = formatTime(timeLeft)
			self.timer:SetText(text)
		else
			self:SetScript('OnUpdate', nil)
			self.timer:SetText(nil)
		end
		self.elapsed = 0
	end
end

-- Table
function F.CopyTable(source, target)
	for key, value in pairs(source) do
		if type(value) == 'table' then
			if not target[key] then target[key] = {} end
			for k in pairs(value) do
				target[key][k] = value[k]
			end
		else
			target[key] = value
		end
	end
end

function F.SplitList(list, variable, cleanup)
	if cleanup then wipe(list) end

	for word in variable:gmatch('%S+') do
		list[word] = true
	end
end

-- Itemlevel
local iLvlDB = {}
local itemLevelString = gsub(ITEM_LEVEL, '%%d', '')
local enchantString = gsub(ENCHANTED_TOOLTIP_LINE, '%%s', '(.+)')
local essenceTextureID = 2975691
local tip = CreateFrame('GameTooltip', 'FreeUI_iLvlTooltip', nil, 'GameTooltipTemplate')

local texturesDB, essencesDB = {}, {}
function F:InspectItemTextures(clean, grabTextures)
	wipe(texturesDB)
	wipe(essencesDB)

	for i = 1, 5 do
		local tex = _G[tip:GetName()..'Texture'..i]
		local texture = tex and tex:GetTexture()
		if not texture then break end

		if grabTextures then
			if texture == essenceTextureID then
				local selected = (texturesDB[i-1] ~= essenceTextureID and texturesDB[i-1]) or nil
				essencesDB[i] = {selected, tex:GetAtlas(), texture}
				if selected then texturesDB[i-1] = nil end
			else
				texturesDB[i] = texture
			end
		end

		if clean then tex:SetTexture() end
	end

	return texturesDB, essencesDB
end

function F:InspectItemInfo(text, iLvl, enchantText)
	local itemLevel = strfind(text, itemLevelString) and strmatch(text, '(%d+)%)?$')
	if itemLevel then iLvl = tonumber(itemLevel) end
	local enchant = strmatch(text, enchantString)
	if enchant then enchantText = enchant end

	return iLvl, enchantText
end

function F.GetItemLevel(link, arg1, arg2, fullScan)
	if fullScan then
		F:InspectItemTextures(true)
		tip:SetOwner(UIParent, 'ANCHOR_NONE')
		tip:SetInventoryItem(arg1, arg2)

		local iLvl, enchantText, gems, essences
		gems, essences = F:InspectItemTextures(nil, true)

		for i = 1, tip:NumLines() do
			local line = _G[tip:GetName()..'TextLeft'..i]
			if line then
				local text = line:GetText() or ''
				iLvl, enchantText = F:InspectItemInfo(text, iLvl, enchantText)
				if enchantText then break end
			end
		end

		return iLvl, enchantText, gems, essences
	else
		if iLvlDB[link] then return iLvlDB[link] end

		tip:SetOwner(UIParent, 'ANCHOR_NONE')
		if arg1 and type(arg1) == 'string' then
			tip:SetInventoryItem(arg1, arg2)
		elseif arg1 and type(arg1) == 'number' then
			tip:SetBagItem(arg1, arg2)
		else
			tip:SetHyperlink(link)
		end

		for i = 2, 5 do
			local line = _G[tip:GetName()..'TextLeft'..i]
			if line then
				local text = line:GetText() or ''
				local found = strfind(text, itemLevelString)
				if found then
					local level = strmatch(text, '(%d+)%)?$')
					iLvlDB[link] = tonumber(level)
					break
				end
			end
		end

		return iLvlDB[link]
	end
end

-- NPC id
function F.GetNPCID(guid)
	local id = tonumber((guid or ''):match('%-(%d-)%-%x-$'))
	return id
end

-- Chat channel check
F.CheckChat = function(warning)
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return 'INSTANCE_CHAT'
	elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
		if warning and (UnitIsGroupLeader('player') or UnitIsGroupAssistant('player') or IsEveryoneAssistant()) then
			return 'RAID_WARNING'
		else
			return 'RAID'
		end
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		return 'PARTY'
	end
	return 'SAY'
end


