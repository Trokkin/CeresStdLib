ofstream = {}
local ofstream = ofstream
ofstream.raw_prefix = ']]i([['
ofstream.raw_suffix = ']])--[['
ofstream.raw_size = 256 - #ofstream.raw_prefix - #ofstream.raw_suffix
ofstream.load_ability = FourCC('ANdc')

function ofstream.open(filename)
	ofstream.name = filename
    PreloadGenClear()
	Preload('")\nendfunction\n//! beginusercode\nlocal p={} local i=function(s)table.insert(p,s)end--[[')
end

function ofstream.write(s)
	for i=1, #s, ofstream.raw_size do
		Preload(ofstream.raw_prefix..s:sub(i,i+ofstream.raw_size-1)..ofstream.raw_suffix)
	end
end

function ofstream.close()
    Preload(']]BlzSetAbilityTooltip('..ofstream.load_ability..', table.concat(p), 0) print("File '.. ofstream.name ..' loaded successfully!")\n//! endusercode\nfunction AAA takes nothing returns nothing\n//')
	PreloadGenEnd( ofstream.name )
	ofstream.name = nil
end

function loadfile(filename)
    local s = BlzGetAbilityTooltip(ofstream.load_ability, 0)
    BlzSetAbilityTooltip(ofstream.load_ability, '', 0)
    Preloader(filename)
    local loaded = BlzGetAbilityTooltip(ofstream.load_ability, 0)
    BlzSetAbilityTooltip(ofstream.load_ability, s, 0)
    return loaded
end