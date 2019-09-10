--- File Input/Output
fio = {}
local fio = fio
fio.raw_prefix = ']]i([['
fio.raw_suffix = ']])--[['
fio.raw_size = 256 - #fio.raw_prefix - #fio.raw_suffix
fio.load_ability = FourCC('ANdc')
fio.str_empty_file = 'FIO_EMPTY_FILE'

--- Returns string saved in file found on given path, else nil
---@param filename string
---@return string
function fio.loadfile(filename)
    local s = BlzGetAbilityTooltip(fio.load_ability, 0)
    BlzSetAbilityTooltip(fio.load_ability, fio.str_empty_file, 0)
    Preloader(filename)
    local loaded = BlzGetAbilityTooltip(fio.load_ability, 0)
    BlzSetAbilityTooltip(fio.load_ability, s, 0)
    if loaded == fio.str_empty_file then
        return nil
    end
    return loaded
end

--- Saves given string to a file on given path
--- that can be loaded with `.loadfile()`
---@param filename string
---@param string string
function fio.savefile(filename, string)
    PreloadGenClear()
	Preload('")\nendfunction\n//! beginusercode\nlocal p={} local i=function(s)table.insert(p,s)end--[[')
	for i=1, #string, fio.raw_size do
		Preload(fio.raw_prefix..string:sub(i,i+fio.raw_size-1)..fio.raw_suffix)
	end
    Preload(']]BlzSetAbilityTooltip('..fio.load_ability..', table.concat(p), 0) print("File '.. fio.name ..' loaded successfully!")\n//! endusercode\nfunction AAA takes nothing returns nothing\n//')
	PreloadGenEnd( fio.name )
end