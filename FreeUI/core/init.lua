local addonName, ns = ...

ns[1] = {} -- F, Functions
ns[2] = {} -- C, Constants/Config
ns[3] = {} -- L, Localisation

_G[addonName] = ns

FreeUIGlobalConfig, FreeUIConfig = {}, {}


local F, C, L = unpack(ns)

local pairs, next, tinsert = pairs, next, table.insert

local events = {}

local host = CreateFrame('Frame')
host:SetScript('OnEvent', function(_, event, ...)
	for func in pairs(events[event]) do
		if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
			func(event, CombatLogGetCurrentEventInfo())
		else
			func(event, ...)
		end
	end
end)

function F:RegisterEvent(event, func, unit1, unit2)
	if not events[event] then
		events[event] = {}
		if unit1 then
			host:RegisterUnitEvent(event, unit1, unit2)
		else
			host:RegisterEvent(event)
		end
	end

	events[event][func] = true
end

function F:UnregisterEvent(event, func)
	local funcs = events[event]
	if funcs and funcs[func] then
		funcs[func] = nil

		if not next(funcs) then
			events[event] = nil
			host:UnregisterEvent(event)
		end
	end
end



local modules, initQueue = {}, {}

function F:RegisterModule(name)
	if modules[name] then print('Module <'..name..'> has been registered.') return end
	local module = {}
	module.name = name
	modules[name] = module

	tinsert(initQueue, module)
	return module
end

function F:GetModule(name)
	if not modules[name] then print('Module <'..name..'> does not exist.') return end

	return modules[name]
end



F:RegisterEvent('PLAYER_LOGIN', function()
	for _, module in next, initQueue do
		if module.OnLogin then
			module:OnLogin()
		else
			print('Module <'..module.name..'> does not loaded.')
		end
	end

	C_Timer.After(3, collectgarbage)
end)



local hider = CreateFrame('Frame', 'FreeUIHider', UIParent)
hider:Hide()



