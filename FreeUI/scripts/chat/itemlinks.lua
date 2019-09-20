local F, C, L = unpack(select(2, ...))
local CHAT = F:GetModule('Chat')


-- Enhance item links on chat
local function GetHyperlink(Hyperlink, texture)
	if (not texture) then
		return Hyperlink
	else
		return '|T'..texture..':0|t ' .. Hyperlink
	end
end

local function SetChatLinkIcon(Hyperlink)
	local schema, id = string.match(Hyperlink, '|H(%w+):(%d+):')
	local texture
	if (schema == 'item') then
		texture = select(10, GetItemInfo(tonumber(id)))
	elseif (schema == 'spell') then
		texture = select(3, GetSpellInfo(tonumber(id)))
	elseif (schema == 'achievement') then
		texture = select(10, GetAchievementInfo(tonumber(id)))
	end
	return GetHyperlink(Hyperlink, texture)
end


local Caches = {}

local function ChatItemSlot(Hyperlink)
	if (Caches[Hyperlink]) then
		return Caches[Hyperlink]
	end
	local slot
	local link = string.match(Hyperlink, '|H(.-)|h')
	local name, _, quality, level, _, class, subclass, _, equipSlot = GetItemInfo(link)
	if (equipSlot == 'INVTYPE_CLOAK' or equipSlot == 'INVTYPE_TRINKET' or equipSlot == 'INVTYPE_FINGER' or equipSlot == 'INVTYPE_NECK') then
		slot = _G[equipSlot] or equipSlot
	elseif (equipSlot == 'INVTYPE_RANGEDRIGHT') then
		slot = subclass
	elseif (equipSlot and string.find(equipSlot, 'INVTYPE_')) then
		slot = format('%s-%s', subclass or '', _G[equipSlot] or equipSlot)
	elseif (class == ARMOR) then
		slot = format('%s-%s', subclass or '', class)
	elseif (subclass and string.find(subclass, RELICSLOT)) then
		slot = RELICSLOT
	elseif (subclass and subclass == MOUNTS) then
		slot = MOUNTS
	end
	if (slot) then
		Hyperlink = Hyperlink:gsub('|h%[(.-)%]|h', '|h['..slot..': '..name..']|h')
		Caches[Hyperlink] = Hyperlink
	end
	return Hyperlink
end


function CHAT:UpdateChatItemLink(_, msg, ...)
	msg = gsub(msg, '(|Hitem:%d+:.-|h.-|h)', ChatItemSlot)
	msg = gsub(msg, '(|H%w+:%d+:.-|h.-|h)', SetChatLinkIcon)
	return false, msg, ...
end


-- Show item's real color for BN chat
local queuedMessages = {}

local function GetLinkColor(data)
	local type, arg1, arg2, arg3 = split(':', data)
	if(type == 'item') then
		local _, _, quality = GetItemInfo(arg1)
		if(quality) then
			local _, _, _, color = GetItemQualityColor(quality)
			return '|c' .. color
		else
			return nil, true
		end
	elseif(type == 'quest') then
		if(arg2) then
			return ConvertRGBtoColorString(GetQuestDifficultyColor(arg2))
		else
			return '|cffffd100'
		end
	elseif(type == 'currency') then
		local link = GetCurrencyLink(arg1)
		if(link) then
			return sub(link, 0, 10)
		else
			return '|cffffffff'
		end
	elseif(type == 'battlepet') then
		if(arg3 ~= -1) then
			local _, _, _, color = GetItemQualityColor(arg3)
			return '|c' .. color
		else
			return '|cffffd200'
		end
	elseif(type == 'garrfollower') then
		local _, _, _, color = GetItemQualityColor(arg2)
		return '|c' .. color
	elseif(type == 'spell') then
		return '|cff71d5ff'
	elseif(type == 'achievement' or type == 'garrmission') then
		return '|cffffff00'
	elseif(type == 'trade' or type == 'enchant') then
		return '|cffffd000'
	elseif(type == 'instancelock') then
		return '|cffff8000'
	elseif(type == 'glyph' or type == 'journal') then
		return '|cff66bbff'
	elseif(type == 'talent' or type == 'battlePetAbil' or type == 'garrfollowerability') then
		return '|cff4e96f7'
	elseif(type == 'levelup') then
		return '|cffff4e00'
	end
end

local function UpdateLinkColor(self, event, message, ...)
	for link, data in gmatch(message, '(|H(.-)|h.-|h)') do
		local color, queue = GetLinkColor(data)
		if(queue) then
			table.insert(queuedMessages, {self, event, message, ...})
			return true
		elseif(color) then
			local matchLink = '|H' .. data .. '|h.-|h'
			message = gsub(message, matchLink, color .. link .. '|r', 1)
		end
	end

	return false, message, ...
end

local f = CreateFrame('Frame')
f:RegisterEvent('GET_ITEM_INFO_RECEIVED')
f:SetScript('OnEvent', function()
	if(#queuedMessages > 0) then
		for index, data in next, queuedMessages do
			ChatFrame_MessageEventHandler(unpack(data))
			queuedMessages[index] = nil
		end
	end
end)


function CHAT:ItemLinks()
	if not C.chat.itemLinks then return end

	ChatFrame_AddMessageEventFilter('CHAT_MSG_LOOT', self.UpdateChatItemLink)
	ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL', self.UpdateChatItemLink)
	ChatFrame_AddMessageEventFilter('CHAT_MSG_SAY', self.UpdateChatItemLink)
	ChatFrame_AddMessageEventFilter('CHAT_MSG_YELL', self.UpdateChatItemLink)
	ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER', self.UpdateChatItemLink)
	ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER_INFORM', self.UpdateChatItemLink)
	ChatFrame_AddMessageEventFilter('CHAT_MSG_BN_WHISPER', self.UpdateChatItemLink)
	ChatFrame_AddMessageEventFilter('CHAT_MSG_RAID', self.UpdateChatItemLink)
	ChatFrame_AddMessageEventFilter('CHAT_MSG_RAID_LEADER', self.UpdateChatItemLink)
	ChatFrame_AddMessageEventFilter('CHAT_MSG_PARTY', self.UpdateChatItemLink)
	ChatFrame_AddMessageEventFilter('CHAT_MSG_PARTY_LEADER', self.UpdateChatItemLink)
	ChatFrame_AddMessageEventFilter('CHAT_MSG_GUILD', self.UpdateChatItemLink)
	ChatFrame_AddMessageEventFilter('CHAT_MSG_BATTLEGROUND', self.UpdateChatItemLink)

	ChatFrame_AddMessageEventFilter('CHAT_MSG_BN_WHISPER', UpdateLinkColor)
	ChatFrame_AddMessageEventFilter('CHAT_MSG_BN_WHISPER_INFORM', UpdateLinkColor)
end