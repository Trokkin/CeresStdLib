netstream = {}
netstream.listeners = {}

function netstream.onRecieve(name, f)
	if netstream.listeners[name] == nil then
		netstream.listeners[name] = {}
		netstream.recieved[name] = {}
		netstream.listener[name] = CreateTrigger()
		for p in players do
			BlzTriggerRegisterPlayerSyncEvent(netstream.listener[name], p, name, true)
			BlzTriggerRegisterPlayerSyncEvent(netstream.listener[name], p, name, false)
		end
		TriggerAddAction(function ()
			local s = BlzGetTriggerSyncData()
			local p = GetTriggerPlayer()
		    if s:sub(1,2) == '^{' then
				netstream.recieved[name][p] = {}
		        s = s:sub(3)
		    end
		    if netstream.recieved[name][p] == nil then
		        Log.warn('netstream', name, 'headless package!')
		        return
		    end
		    if s:sub(-2) == '^}' then
		        table.insert(netstream.recieved[name][p],s:sub(1, -3))
		        s = table.concat(netstream.recieved[name][p])
				netstream.recieved[name][p] = nil
				for l in netstream.listeners[name] do
					f(s, p)
				end
		    else
		        table.insert(netstream.recieved[name][p], s)
		    end
		end)
	end
	table.insert(netstream.listeners[name], f)
end

function netstream.send(name, s)
	table.insert(netstream.queue[name], '^{'..s..'^}')
	local timer = CreateTimer()
	local i = 1
	TimerStart(timer, 1/32., true, function()
		while i < #s do
			-- Assuming it returns false before desync
			if not BlzSendSyncData(name, ofstream.raw_prefix..s:sub(i,i+254)..ofstream.raw_suffix) then
				return
			end
			i = i + 255
		end
		DestroyTimer(timer)
	end)
end
