require('CeresStdLib.base.Basics')

BENCHMARK_MULTIPLIER = 1000000

function measure_run_time(f, count)
	local clock = os.clock
	local start = clock()
	for i = 1, count do
		f()
	end
	return clock() - start
end

function benchmark(f_name, f)
	local t = execute(function() return measure_run_time(f, BENCHMARK_MULTIPLIER) end)
	if t ~= nil then
		Log.info(BENCHMARK_MULTIPLIER .. ' runs of ' .. f_name .. ' takes ' .. t .. ' sec to complete')
	else
		Log.warn(f_name .. ' failed to execute')
	end
end
