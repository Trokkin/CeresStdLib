filesystem = {}
local fs = filesystem
local io = require('CeresStdLib.util.fio')
local log = require('CeresStdLib.base.log')
fs.separator = '/'
fs.index = 'index.pld'
fs.index_header = 'INDEX\n'

---@class folder
local folder = {}
folder.__index = folder

---@param path string
---@param name string
---@param parent folder
---@param o folder
local function make_directory(path, name, parent, o)
	if io.loadfile(path .. fs.index) then
		Log.error('[folder:mkdir] "' .. path .. '" already exists')
		return nil
	end
	io.savefile(path .. fs.index, fs.index_header)
	if not io.loadfile(path .. fs.index) then
		Log.error('[folder:mkdir] Could not create "' .. path .. '"')
		return nil
	end
	o = setmetatable(o or {}, parent)
	o.__index = o
	o.name = name
	o.path = path
	o.root = parent
	o.files = {}
	o.subdir = {}
	return o
end

---@param path string
---@param name string
---@param parent folder
---@param o folder
local function load_directory(path, name, parent, o)
	local index = io.loadfile(path .. fs.index)
	if index == nil then
		return nil
	end
	if index:sub(1, #fs.index_header) ~= fs.index_header then
		Log.error('[folder:lddir] Corrupt index file: "' .. path .. fs.index .. '" ('.. index:sub(1, #fs.index_header) ..')')
		return nil
	end
	o = setmetatable(o or {}, parent)
	o.__index = o
	o.path = path
	o.name = name
	o.root = parent
	o.files = {}
	o.subdir = {}
	index = index:sub(#fs.index_header + 1)
	Log.trace('index: ', index)
	for s in string.gmatch(index, '[^\n]+') do
		Log.trace(s .. " : ".. s:sub(-1))
		if s:sub(-1) == fs.separator then
			s = s:sub(1, -2)
			o.subdir[s] = o:lddir(s)
		else
			o.files[s] = true
		end
	end
	return o
end

---@param name string
---@return folder
function folder:mkdir(name, o)
	local d = make_directory(self.path .. name .. fs.separator, name, self, o)
	self.subdir[name] = d
	return d
end

---@param name string
---@return folder
function folder:lddir(name, o)
	if self.subdir[name] then
		Log.warn('[folder:mkdir] Directory "' .. self.path .. name .. '" already loaded')
		return nil
	end
	local d = load_directory(self.path .. name .. fs.separator, name, self, o)
	self.subdir[name] = d
	return d
end

function folder:flush()
	local s = fs.index_header
	for k,v in pairs(self.subdir) do
		v:flush()
		s = s .. v.name .. fs.separator .. '\n'
	end
	for k,v in pairs(self.files) do
		s = s .. k .. '\n'
	end
	io.savefile(self.path .. fs.index, s)
end

---@param name string
---@return boolean
function folder:touch(name)
	if self.files[name] or io.loadfile(self.path .. name) then
		Log.error('[folder:touch] "' .. self.path .. name .. '" already exists')
		return false
	end
	io.savefile(self.path .. name, 'touched')
	if not io.loadfile(self.path .. name) then
		Log.error('[folder:touch] Could not create "' .. self.path .. name .. '"')
		return false
	end
	self.files[name] = true
	return true
end

---@param name string
---@return boolean
function folder:delete(name)
	return io.deletefile(self.path .. name)
end

---@param path string
function folder:relative(path, create)
	local dir = self
	create = create or false
	for p in path:gmatch('[^'..fs.separator..']+') do
		Log.trace('step ', p)
		if not dir.subdir[p] then
			if create then
				dir:mkdir(p)
			else
				Log.error('[folder:relative] No such directory "' .. dir.path .. p .. '"')
				return nil
			end
		end
		dir = dir.subdir[p]
	end
	return dir
end

init(function()
	fs.root = load_directory('', 'root', folder)
	if not fs.root then
		fs.root = make_directory('', 'root', folder)
	end
end)

return fs