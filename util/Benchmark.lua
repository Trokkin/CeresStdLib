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
	local t = execute(measure_run_time(f, BENCHMARK_MULTIPLIER))
	print('Benchmark ' .. f_name .. ' takes ' .. t .. ' ms to complete on average')
end
