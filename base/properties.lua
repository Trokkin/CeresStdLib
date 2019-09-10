local log = require('CeresStdLib.base.Log')

--- Creates `__properties` table for the object.
--- Replaces `__index` and `__newindex` to use named properties described as
--- `{ get : function, set: function }`. Absent getters or setters throw an error.
---@param object table
function enableProperties(object)
	if object.__properties ~= nil then return end
	object.__properties = {}
	object.__index = function(self, key)
		if object.__properties[key] then
			if object.__properties[key].get then
				return object.__properties[key].get(self)
			else
				log.error('Tried to access unaccessible property "', key, '"')
			end
			return nil
		end
		if self == object then
			return nil
		end
        return object[key]
	end
	object.__newindex = function(self, key, value)
	    if object.__properties[key] then
			if object.__properties[key].set then
				object.__properties[key].set(self, value)
			else
				log.error('Tried to modify unmodifiable property "', key, '" with value "', tostring(value), '"')
			end
			return
		end
		local r = rawget(object, key)
		if r ~= nil then
			-- fall back to write into parent
			if self == object then
				rawset(self, object, value)
			else
				object[key] = value
			end
		else
	        rawset(self, key, value)
		end
	end
end

return enableProperties