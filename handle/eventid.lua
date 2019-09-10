require('CeresStdLib.handle.handle')
require('CeresStdLib.base.basics')

EventId = EventId or Handle.new()
EventId.__props.name = {
    __ids = {}
}
EventId.__props.name.get = function(t)
    return EventId.__props.name.__ids[t]
end
EventId.__props.name.set = function(t, k)
    EventId.__props.name.__ids[t] = k
end

ceres.addHook("main::before", function()
    for k, v in pairs(_G) do
        if k:sub(1,5) == 'EVENT' and k:sub(7,12) ~= 'CUSTOM' then
            EventId[k]          = v
            _G[k]               = EventId.wrap(v, true)
            _G[k].name          = k:sub(7)
        end
    end
    EventId.__props.name.set    = nil
end)

function EventId.triggering() return EventId.wrap(GetTriggerEventId(), true) end