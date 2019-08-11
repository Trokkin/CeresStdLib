netstream = {}
netstream.channels = {}

function netstream.onRecieve(name, f)
	if netstream.channels[name] == nil then
		local ch = {}
		netstream.channels[name] = ch
		ch.listeners = {}
		ch.recieved = {}
		ch.queue = {}
		ch.listener = CreateTrigger()
		for i, p in pairs(players) do
			BlzTriggerRegisterPlayerSyncEvent(ch.listener, p, name, true)
			BlzTriggerRegisterPlayerSyncEvent(ch.listener, p, name, false)
		end
		TriggerAddAction(ch.listener, function ()
			local s = BlzGetTriggerSyncData()
			local p = GetTriggerPlayer()
		    if s:sub(1,2) == '^{' then
				ch.recieved[p] = {}
		        s = s:sub(3)
		    end
		    if ch.recieved[p] == nil then
		        Log.warn('netstream', name, 'headless package!')
		        return
		    end
		    if s:sub(-2) == '^}' then
		        table.insert(ch.recieved[p],s:sub(1, -3))
		        s = table.concat(ch.recieved[p])
				ch.recieved[p] = nil
				for i, f_ in ipairs(ch.listeners) do
					f_(s, p)
				end
		    else
		        table.insert(ch.recieved[p], s)
		    end
		end)
	end
	table.insert(netstream.channels[name].listeners, f)
end

function netstream.send(name, s)
	local ch = netstream.channels[name]
	if ch == nil then return end
	table.insert(ch.queue, '^{'..s..'^}')
	if ch.timer == nil then
		local i = 1
		local n = 1
		local c = 0
		ch.timer = CreateTimer()
		TimerStart(ch.timer, 1/32., true, function()
			while #ch.queue > 0 do
				local s_ = ch.queue[1]
				while i < #s_ do
					-- Assuming it returns false before desync
					Log.info(s_:sub(i,i+254))
					if not BlzSendSyncData(name, s_:sub(i,i+254)) then
						n = n + 1
						return
					end
					c = c + 1
					i = i + 255
				end
				i = 1
				table.remove(ch.queue, 1)
			end
			Log.info('net.send took', n, 'seconds', c, 'packages')
			DestroyTimer(ch.timer)
			ch.timer = nil
		end)
	end
end
