require('CeresStdLib.base.Log')

-- Enables player(0) to turn chat into Lua shell.
-- Run anything you want.

local shell = CreateTrigger()
TriggerRegisterPlayerChatEvent(shell, Player(0), '%', false)
TriggerAddAction(shell, function()
    local s = GetEventPlayerChatString()
    if s:sub(1,1) ~= '%' then
        return
    end
    s = s:sub(2)
    local f = load(s)
    if not f then
        Log.error('invalid shell command "' .. s .. '"')
    end
    f()
end)


function KillShell()
	if shell ~= nil then
		DestroyTrigger(shell)
		shell = nil
	end
end