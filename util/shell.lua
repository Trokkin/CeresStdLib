require('CeresStdLib.base.log')

-- Enables player(0) to turn chat into Lua shell.
-- Run anything you want.

local cache = {}

local shell = CreateTrigger()
TriggerRegisterPlayerChatEvent(shell, Player(0), '$', false)
TriggerAddAction(shell, function()
    local s = GetEventPlayerChatString()
    if s:sub(1,1) ~= '$' then
        return
    end
    s = s:sub(2)
    ExecuteString(s)
end)

function ExecuteString(s)
    local f = load(s)
    if not f then
        Log.error('invalid shell command "' .. s .. '"')
    end
    print(f())
    table.insert(cache, s)
end

local buffer = {''}
local chatbuffer = CreateTrigger()
TriggerRegisterPlayerChatEvent(chatbuffer, Player(0), '%', false)
TriggerAddAction(chatbuffer, function()
    local s = GetEventPlayerChatString()
    if s:sub(1,1) ~= '%' then
        return
    end
    s = s:sub(2)
    table.insert(buffer, s)
end)

function ExecuteBuffer()
    ExecuteString(table.concat(buffer, '\n'))
    buffer = {''}
end

function KillShell()
	if shell ~= nil then
		DestroyTrigger(shell)
		shell = nil
	end
end

function SaveShell()
    fio.open("LuaShellDump.pld")
    fio.write(table.concat(cache, '\n'))
    fio.close()
end

function LoadShell()
    ExecuteString(fio.loadfile("LuaShellDump.pld"))
end
