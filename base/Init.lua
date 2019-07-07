local arr = {}

function init(f)
	if arr ~= nil then
		table.insert(arr, f)
	else
		ceres.catch(f)
	end
end

TimerStart(CreateTimer(), 0.00, false, function()
	for i, f in pairs(arr) do
		ceres.catch(f)
	end
	arr = nil
	DestroyTimer(GetExpiredTimer())
end)
