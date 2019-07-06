CHARMAP =
	".................................!.#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[.]^_`abcdefghijklmnopqrstuvwxyz{|}~................................................................................................................................."

function toRawCode(int)
	res = ''
	for i = 1, 4 do
		res = CHARMAP[math.floor(int / 256)] .. res
		int = int % 256
	end
	return res
end

function fromRawCode(raw)
	res = 0
	f = 1
	for i = 1, 4 do
		res = res + f * (CHARMAP:find(raw:sub(i, i), nil, true) - 1)
		f = f * 256
	end
	return res
end
