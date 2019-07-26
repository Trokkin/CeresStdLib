function toRawCode(int)
	local res = ''
	for i = 1, 4 do
		res = string.char(int % 256) .. res
		int = int // 256
	end
	return res
end

function fromRawCode(raw)
	return FourCC(raw)
end
