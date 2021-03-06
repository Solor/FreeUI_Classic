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
end