local F, C, L = unpack(select(2, ...))
local MISC = F:GetModule('Misc')


local pairs, select, next, wipe = pairs, select, next, wipe
local UnitGUID, GetItemInfo = UnitGUID, GetItemInfo
local GetContainerItemLink, GetInventoryItemLink = GetContainerItemLink, GetInventoryItemLink
local EquipmentManager_UnpackLocation, EquipmentManager_GetItemInfoByLocation = EquipmentManager_UnpackLocation, EquipmentManager_GetItemInfoByLocation
local BAG_ITEM_QUALITY_COLORS = BAG_ITEM_QUALITY_COLORS
local C_Timer_After = C_Timer.After

local inspectSlots = {
	"Head",
	"Neck",
	"Shoulder",
	"Shirt",
	"Chest",
	"Waist",
	"Legs",
	"Feet",
	"Wrist",
	"Hands",
	"Finger0",
	"Finger1",
	"Trinket0",
	"Trinket1",
	"Back",
	"MainHand",
	"SecondaryHand",
	"Ranged",
}

function MISC:GetSlotAnchor(index)
	if not index then return end

	if index <= 5 or index == 9 or index == 15 then
		return "BOTTOMLEFT", 40, 20
	elseif index == 16 then
		return "BOTTOMRIGHT", -40, 2
	elseif index == 17 then
		return "BOTTOMLEFT", 40, 2
	else
		return "BOTTOMRIGHT", -40, 20
	end
end

function MISC:CreateItemTexture(slot, relF, x, y)
	local icon = slot:CreateTexture(nil, "ARTWORK")
	icon:SetPoint(relF, x, y)
	icon:SetSize(14, 14)
	icon:SetTexCoord(unpack(C.TexCoord))
	icon.bg = F.CreateBDFrame(icon)
	icon.bg:Hide()

	return icon
end

function MISC:CreateColorBorder()
	if F then return end
	local frame = CreateFrame("Frame", nil, self)
	frame:SetAllPoints()
	frame:SetFrameLevel(5)
	self.colorBG = F.CreateSD(frame, 4, 4)
end

function MISC:CreateItemString(frame, strType)
	if frame.fontCreated then return end

	for index, slot in pairs(inspectSlots) do
		if index ~= 4 then
			local slotFrame = _G[strType..slot.."Slot"]
			local relF, x, y = MISC:GetSlotAnchor(index)
			slotFrame.enchantText = F.CreateFS(slotFrame, 'pixel')
			slotFrame.enchantText:ClearAllPoints()
			slotFrame.enchantText:SetPoint(relF, slotFrame, x, y)
			slotFrame.enchantText:SetTextColor(0, 1, 0)
			for i = 1, 5 do
				local offset = (i-1)*18 + 5
				local iconX = x > 0 and x+offset or x-offset
				local iconY = index > 15 and 20 or 2
				slotFrame["textureIcon"..i] = MISC:CreateItemTexture(slotFrame, relF, iconX, iconY)
			end
			MISC.CreateColorBorder(slotFrame)
		end
	end

	frame.fontCreated = true
end

function MISC:ItemBorderSetColor(slotFrame, r, g, b)
	if slotFrame.colorBG then
		slotFrame.colorBG:SetBackdropBorderColor(r, g, b)
	end
	if slotFrame.bg then
		slotFrame.bg:SetBackdropBorderColor(r, g, b)
	end
end

local pending = {}
function MISC:RefreshButtonInfo()
	if InspectFrame and InspectFrame.unit then
		for index, slotFrame in pairs(pending) do
			local link = GetInventoryItemLink(InspectFrame.unit, index)
			if link then
				local quality = select(3, GetItemInfo(link))
				if quality then
					local color = ITEM_QUALITY_COLORS[quality]
					MISC:ItemBorderSetColor(slotFrame, color.r, color.g, color.b)
					pending[index] = nil
				end
			end
		end

		if not next(pending) then
			self:Hide()
			return
		end
	else
		wipe(pending)
		self:Hide()
	end
end

function MISC:ItemLevel_SetupLevel(frame, strType, unit)
	if not UnitExists(unit) then return end

	MISC:CreateItemString(frame, strType)

	for index, slot in pairs(inspectSlots) do
		if index ~= 4 then
			local slotFrame = _G[strType..slot.."Slot"]
			slotFrame.enchantText:SetText("")
			for i = 1, 5 do
				local texture = slotFrame["textureIcon"..i]
				texture:SetTexture(nil)
				texture.bg:Hide()
			end
			MISC:ItemBorderSetColor(slotFrame, 0, 0, 0)

			local itemTexture = GetInventoryItemTexture(unit, index)
			if itemTexture then
				local link = GetInventoryItemLink(unit, index)
				if link then
					local quality = select(3, GetItemInfo(link))
					if quality then
						local color = BAG_ITEM_QUALITY_COLORS[quality]
						MISC:ItemBorderSetColor(slotFrame, color.r, color.g, color.b)
					else
						pending[index] = slotFrame
						MISC.QualityUpdater:Show()
					end

					local _, enchant, gems = F.GetItemLevel(link, unit, index, true)
					if enchant then
						slotFrame.enchantText:SetText(enchant)
					end

					for i = 1, 5 do
						local texture = slotFrame["textureIcon"..i]
						if gems and next(gems) then
							local index, gem = next(gems)
							texture:SetTexture(gem)
							texture.bg:Show()

							gems[index] = nil
						end
					end
				else
					pending[index] = slotFrame
					MISC.QualityUpdater:Show()
				end
			end
		end
	end
end

function MISC:ItemLevel_UpdatePlayer()
	MISC:ItemLevel_SetupLevel(CharacterFrame, "Character", "player")
end

function MISC:ItemLevel_UpdateInspect(...)
	local guid = ...
	if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
		MISC:ItemLevel_SetupLevel(InspectFrame, "Inspect", InspectFrame.unit)
	end
end


function MISC:ItemLevel()
	if not C.general.itemLevel then return end

	-- iLvl on CharacterFrame
	CharacterFrame:HookScript("OnShow", MISC.ItemLevel_UpdatePlayer)
	F:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", MISC.ItemLevel_UpdatePlayer)

	-- iLvl on InspectFrame
	F:RegisterEvent("INSPECT_READY", self.ItemLevel_UpdateInspect)

	-- Update item quality
	MISC.QualityUpdater = CreateFrame("Frame")
	MISC.QualityUpdater:Hide()
	MISC.QualityUpdater:SetScript("OnUpdate", MISC.RefreshButtonInfo)
end