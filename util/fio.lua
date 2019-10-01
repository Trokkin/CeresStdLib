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
        Log.trace('Not found ' .. filename)
        return nil
    end
    Log.trace('Found ' .. filename)
    return loaded
end

--- Saves given string to a file on given path
--- that can be loaded with `.loadfile()`
--- `string` defaults to `fio.str_empty_file`
---@param filename string
---@param string string
function fio.savefile(filename, string)
    if string == nil then
        string = fio.str_empty_file
    end
    PreloadGenClear()
	Preload('")\nendfunction\n//! beginusercode\nlocal p={} local i=function(s)table.insert(p,s)end--[[')
	for i=1, #string, fio.raw_size do
		Preload(fio.raw_prefix..string:sub(i,i+fio.raw_size-1)..fio.raw_suffix)
	end
    Preload(']]BlzSetAbilityTooltip('..fio.load_ability..', table.concat(p), 0)\n//! endusercode\nfunction AAA takes nothing returns nothing\n//')
    PreloadGenEnd( filename )
    Log.trace('Saved ' .. filename)
end

function fio.deletefile(filename)
    if fio.loadfile(filename) then
        PreloadGenClear()
        PreloadGenEnd( filename )    
        return true
    end
    return false
end

function fio.appendfile(filename, string)
    local s = fio.loadfile(filename)
    fio.savefile(s .. string)
    return s ~= nil, s
end

return fio