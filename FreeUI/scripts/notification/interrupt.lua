local F, C, L = unpack(select(2, ...))
local module = F:GetModule('Notification')

function module:Interrupt()
	local interruptSound = C.AssetsPath..'sound\\interrupt.ogg'
	local frame = CreateFrame('Frame')
	frame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	frame:SetScript('OnEvent', function(self)
		local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, _, destName, _, _, _, spellName, _, _, extraskillName = CombatLogGetCurrentEventInfo()
		if not sourceGUID or sourceName == destName then return end

		local inInstance, instanceType = IsInInstance()
		--local infoText = infoType[eventType]
		if ((sourceGUID == UnitGUID('player')) or (sourceGUID == UnitGUID('pet'))) then
			if (eventType == 'SPELL_INTERRUPT') then
				if C.notification.interrupt then
					PlaySoundFile(interruptSound, 'Master')
				end

				if C.notification.interruptAnnounce and inInstance and IsInGroup() then
					--SendChatMessage(L['NOTIFICATION_INTERRUPTED']..destName..' '..GetSpellLink(spellID), say)
					SendChatMessage(format(L['NOTIFICATION_INTERRUPTED']..destName..' '..extraskillName), say)
				end
			end
		end
	end)
end