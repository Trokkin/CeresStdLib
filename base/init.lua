local arr		= {}

--- Ensures that `f` will be executed not before the game begins (timer 0.0)
function init(f)
	if arr ~= nil then
		table.insert(arr, f)
	else
		ceres.catch(f)
	end
end

local t = CreateTimer()
TimerStart(t, 0.00, false, function()
	for i, f in pairs(arr) do
		ceres.catch(f)
	end
	arr = nil
	DestroyTimer(t)
end)