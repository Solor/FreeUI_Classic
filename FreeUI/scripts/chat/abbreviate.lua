local F, C, L = unpack(select(2, ...))
local module = F:GetModule('Chat')


local gsub, match, format = string.gsub, string.match, string.format

local hooks = {}

local function GetColor(className, isLocal)
	if isLocal then
		local found
		for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
			if v == className then className = k found = true break end
		end
		if not found then
			for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
				if v == className then className = k break end
			end
		end
	end
	local tbl = C.ClassColors[className]
	local color = ('%02x%02x%02x'):format(tbl.r*255, tbl.g*255, tbl.b*255)
	return color
end

local function FormatBNPlayer(misc, id, moreMisc, fakeName, tag, colon)
		local gameAccount = select(6, BNGetFriendInfoByID(id))
		if gameAccount then
			local _, charName, _, _, _, _, _, englishClass = BNGetGameAccountInfo(gameAccount)
			if englishClass and englishClass ~= '' then
				fakeName = '|cFF'..GetColor(englishClass, true)..fakeName..'|r'
			end
	end
	return misc..id..moreMisc..fakeName..tag..(colon == ':' and ':' or colon)
end

local function FormatPlayer(info, name)
	return format('|Hplayer:%s|h%s|h', info, gsub(name, '%-[^|]+', ''))
end

local function AddMessage(self, message, ...)
	message = gsub(message, '%[(%d+)%. 大脚世界频道%]', '世界')
	message = gsub(message, '%[(%d+)%. 大腳世界頻道%]', '世界')
	message = gsub(message, '%[(%d+)%. BigfootWorldChannel%]', 'world')

	-- shorten channel
	message = gsub(message, '|h%[(%d+)%. .-%]|h', '|h%1.|h')

	message = gsub(message, '|Hplayer:(.-)|h%[(.-)%]|h', FormatPlayer)
	message = gsub(message, '(|HBNplayer:%S-|k:)(%d-)(:%S-|h)%[(%S-)%](|?h?)(:?)', FormatBNPlayer)

	-- remove brackets from item and spell links
	--message = gsub(message, '|r|h:(.+)|cff(.+)|H(.+)|h%[(.+)%]|h|r', '|r|h:%1%4')

	return hooks[self](self, message, ...)
end


function module:Abbreviate()
	if not C.chat.abbreviate then return end
	
	for index = 1, NUM_CHAT_WINDOWS do
		if(index ~= 2) then
			local ChatFrame = _G['ChatFrame' .. index]
			hooks[ChatFrame] = ChatFrame.AddMessage
			ChatFrame.AddMessage = AddMessage
		end
	end


	CHAT_FLAG_AFK = '|cff808080[AFK]|r\32'
	CHAT_FLAG_DND = '|cff808080[DND]|r\32'
	CHAT_FLAG_GM = '|cffff0000[GM]|r\32'

	CHAT_WHISPER_GET = 'From. %s:\32'
	CHAT_WHISPER_INFORM_GET = 'To. %s:\32'
	CHAT_BN_WHISPER_GET = 'From. %s:\32'
	CHAT_BN_WHISPER_INFORM_GET = 'To. %s:\32'

	CHAT_GUILD_GET = '|Hchannel:Guild|hG.|h %s:\32'
	CHAT_OFFICER_GET = '|Hchannel:o|hO.|h %s:\32'

	CHAT_PARTY_GET = '|Hchannel:party|hP.|h %s:\32'
	CHAT_PARTY_LEADER_GET = '|Hchannel:party|h|cffffff00!|r P.|h %s:\32'
	CHAT_PARTY_GUIDE_GET = '|Hchannel:party|hP.|h %s:\32'

	CHAT_RAID_GET = '|Hchannel:raid|hR.|h %s:\32'
	CHAT_RAID_WARNING_GET = '[RW] %s:\32'
	CHAT_RAID_LEADER_GET = '|Hchannel:raid|h|cffffff00!|r R.|h %s:\32'

	CHAT_INSTANCE_CHAT_GET = '|Hchannel:INSTANCE_CHAT|hI.|h %s:\32'
	CHAT_INSTANCE_CHAT_LEADER_GET = '|Hchannel:INSTANCE_CHAT|h|cffffff00!|r I.|h %s:\32'

	CHAT_BATTLEGROUND_GET = '|Hchannel:Battleground|hB.|h %s:\32'
	CHAT_BATTLEGROUND_LEADER_GET = '|Hchannel:Battleground|h|cffffff00!|r B.|h %s:\32'

	CHAT_YELL_GET = '|Hchannel:Yell|h%s:\32'
	CHAT_SAY_GET = '|Hchannel:Say|h%s:\32'

	CHAT_CHANNEL_GET = '%s:\32'

	CHAT_MONSTER_PARTY_GET = '|Hchannel:PARTY|hP.|h %s:\32'
	CHAT_MONSTER_SAY_GET = '%s:\32';
	CHAT_MONSTER_WHISPER_GET = '%s:\32'
	CHAT_MONSTER_YELL_GET = '%s:\32'


	CHAT_YOU_CHANGED_NOTICE = '>|Hchannel:%d|h[%s]|h'
	CHAT_YOU_CHANGED_NOTICE_BN = '>|Hchannel:CHANNEL:%d|h[%s]|h'
	CHAT_YOU_JOINED_NOTICE = '+|Hchannel:%d|h[%s]|h'
	CHAT_YOU_JOINED_NOTICE_BN = '+|Hchannel:CHANNEL:%d|h[%s]|h'
	CHAT_YOU_LEFT_NOTICE = '-|Hchannel:%d|h[%s]|h'
	CHAT_YOU_LEFT_NOTICE_BN = '-|Hchannel:CHANNEL:%d|h[%s]|h'

	ERR_SKILL_UP_SI = '|cffffffff%s|r |cff00adf0%d|r'


	if C.isChinses then
		BN_INLINE_TOAST_FRIEND_OFFLINE = '|TInterface\\FriendsFrame\\UI-Toast-ToastIcons.tga:16:16:0:0:128:64:2:29:34:61|t%s |cffff0000离线|r'
		BN_INLINE_TOAST_FRIEND_ONLINE = '|TInterface\\FriendsFrame\\UI-Toast-ToastIcons.tga:16:16:0:0:128:64:2:29:34:61|t%s |cff00ff00上线|r'

		ERR_FRIEND_OFFLINE_S = '%s |cffff0000下线|r'
		ERR_FRIEND_ONLINE_SS = '|Hplayer:%s|h[%s]|h |cff00ff00上线|r'

		ERR_AUCTION_SOLD_S = '|cff1eff00%s|r |cffffffff售出|r'
	end
end





