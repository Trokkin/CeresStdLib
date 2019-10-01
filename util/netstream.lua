netstream = {}
local netstream = netstream
netstream.CHANNEL_NAME = 'STD_NETSTREAM'

local function createChannel()
	local ch = {}
	netstream.channel = ch
	ch.listeners = {}
	ch.recieved = {}
	ch.queue = {}
	ch.listener = CreateTrigger()
	for i, p in pairs(players) do
		BlzTriggerRegisterPlayerSyncEvent(ch.listener, p, netstream.CHANNEL_NAME, true)
		BlzTriggerRegisterPlayerSyncEvent(ch.listener, p, netstream.CHANNEL_NAME, false)
	end
	TriggerAddAction(ch.listener, function ()
		local s = BlzGetTriggerSyncData()
		local p = GetTriggerPlayer()
		if s:sub(1,2) == '^{' then
			if ch.recieved[p] ~= nil then
				Log.warn('netstream discarded unclosed package')
			end
			ch.recieved[p] = {}
	        s = s:sub(3)
	    end
	    if ch.recieved[p] == nil then
	        Log.warn('netstream recieved headless package')
	        return
	    end
	    if s:sub(-2) ~= '^}' then
	        table.insert(ch.recieved[p], s)
	    else
	        table.insert(ch.recieved[p],s:sub(1, -3))
	        s = table.concat(ch.recieved[p])
			ch.recieved[p] = nil
			for i, f_ in ipairs(ch.listeners) do
				f_(s, p)
			end
	    end
	end)
end

local function createChannelTimer()
	local i = 1
	local n = 1
	local c = 0
	local ch = netstream.channel
	ch.timer = CreateTimer()
	TimerStart(ch.timer, 1/32., true, function()
		while #ch.queue > 0 do
			local s_ = ch.queue[1]
			while i < #s_ do
				-- TODO: Check if it returns false before desync to notice that no more data should be synced
				if not BlzSendSyncData(netstream.CHANNEL_NAME, s_:sub(i,i+254)) then
					n = n + 1
					return
				end
				c = c + 1
				i =
					 i + 255
			end
			i = 1
			table.remove(ch.queue, 1)
		end
		DestroyTimer(ch.timer)
		ch.timer = nil
	end)
end

--- Adds listener that will trigger when a string would be synchronized.
--- Listener is called in fashion `f(string, sourcePlayer)`
---@param f function
function netstream.onRecieve(f)
	if netstream.channel == nil then
		createChannel()
	end
	table.insert(netstream.channel.listeners, f)
end

--- Syncs a string to all players (including self).
---@param s string
function netstream.send(s)
	table.insert(netstream.channel.queue, '^{'..s..'^}')
	if netstream.channel.timer == nil then
		createChannelTimer()
	end
end

return netstream