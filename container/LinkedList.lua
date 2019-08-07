require('CeresStdLib.base.Log')

List = {}
List.__index = List

function List:new(o)
	local r = setmetatable({}, self)
	if o ~= nil then
		for k, v in o do
			r:push_back(v)
		end
	end
	return r
end

local function list_pop(self, node)
	if node == nil then
		return nil
	end
	if node == self.iter then
		self.iter = node.prev
	end
	if node == self.backiter then
		self.backiter = node.next
	end
	if node == self.first then
		self.first = node.next
	else
    	node.prev.next = node.next
	end
	if node == self.last then
		self.last = node.prev
	else
		node.next.prev = node.prev
	end
	node.prev = nil
	node.next = nil
	return node.value
end

function List:empty()
	return self.next == nil
end

function List:clear()
	self.next = nil
	self.prev = nil
	self.iter = nil
	self.backiter = nil
end

function List:next()
	if self.iter == nil then
		self.iter = self.first
	else
		self.iter = self.iter.next
	end
	if self.iter == nil then
		return nil
	end
	return self.iter.value
end

function List:prev()
	if self.backiter == nil then
		self.backiter = self.last
	else
		self.backiter = self.backiter.prev
	end
	if self.backiter == nil then
		return nil
	end
	return self.backiter.value
end

function List:reset_iter()
	self.iter = nil
end

function List:reset_backiter()
	self.backiter = nil
end

function List:push_back(v)
	if v == nil then
		Log.error('List:push_back(): expected at least 1 argument')
	end
	self.last = {value = v, prev = self.last}
	if self.first == nil then
		self.first = self.last
	else
		self.last.prev.next = self.last
	end
end

function List:push_front(v)
	if v == nil then
		Log.error('List:push_front(): expected at least 1 argument')
	end
	self.first = {value = v, next = self.first}
	if self.last == nil then
		self.last = self.first
	else
		self.first.next.prev = self.first
	end
end

function List:pop_back()
	return list_pop(self, self.last)
end
function List:pop_front()
	return list_pop(self, self.first)
end
--- Removes element returned by previous call of `next()`
function List:next_remove()
	return list_pop(self, self.iter)
end
--- Removes element returned by previous call of `prev()`
function List:prev_remove()
	return list_pop(self, self.backiter)
end

function List:foldl(func, first)
	local i = self.iter
	self:reset_iter()
	local l = self:next()
	while l do
		first = func(first, l)
		l = self:next()		
	end
	self.iter = i
	return first
end

function List:foldr(func, first)
	local i = self.backiter
	self:reset_backiter()
	local l = self:prev()
	while l do
		first = func(first, l)
		l = self:prev()
	end
	self.backiter = i
	return first
end

function List:filter(func)
	local i = self.iter
	self:reset_iter()
	local l = self:next()
	while l do
		if not func(l) then
			self:next_remove()
		end
		l = self:next()
	end
	self.iter = i
end

function List:tostring(func)
	if func == nil then
		func = tostring
	end
	if List:empty() then return 'List{}' end
	return self:foldl(function (s, v)
		return s .. func(v) .. ', '
	end, 'List{'):sub(1, -3) .. '}'
end

function List:tostringB(func)
	if func == nil then
		func = tostring
	end
	if List:empty() then return 'List{}' end
	return self:foldr(function (s, v)
		return s .. func(v) .. ', '
	end, 'List{'):sub(1, -3) .. '}'
end