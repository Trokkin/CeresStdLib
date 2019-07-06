require('CeresStdLib.base.Execute')

local arr = {}
local arr_count = 0

function init(f)
	arr[arr_count] = f
	arr_count = arr_count + 1
end

TimerStart(
	CreateTimer(),
	0.00,
	false,
	function()
		for i = 0, arr_count - 1 do
			execute(a[i])
		end
	end
)
