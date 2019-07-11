-- Enables player(0) to turn chat into Lua shell.
-- Run anything you want.

local shell = CreateTrigger()
TriggerRegisterPlayerChatEvent(shell, Player(0), '%', false)
TriggerAddAction(shell, function()
    local s = GetEventPlayerChatString()
    s = SubString(s, 1, StringLength(s))
    local f = load(s)
    if not f then
        print('invalid shell command \'' .. s .. '\'')
    end
    f()
end)

function KillShell()
	if shell ~= nil then
		DestroyTrigger(shell)
		shell = nil
	end
end