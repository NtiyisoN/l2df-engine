--- Storage class
-- @classmod l2df.class.storage
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Storage works only with l2df v1.0 and higher')

local Class = core.import 'class'

local Storage = Class:extend()

	--- Storage initialization
	function Storage:init()
		self:reset()
	end

	--- Reset storage flushing all stored data
	function Storage:reset()
		self.list = { }
		self.map = { }
		self.free = { }
		self.length = 0
		self.count = 0
	end

	--- Add new object to storage
	--  @param mixed object
	--  @param[opt] boolean reload
	-- @return number
	-- @return mixed
	function Storage:add(object, reload)
		local id = self:has(object)
		if id and not reload then return id, object end

		if #self.free > 0 then
			id = self.free[#self.free]
			self.free[#self.free] = nil
		else
			self.length = self.length + 1
			id = self.length
		end

		self.list[id] = object
		self.map[object] = id
		self.count = self.count + 1
		return id, object
	end

	--- Add object to storage with provided id
	-- @param mixed object
	-- @param number id
	-- @param boolean reload
	-- @return number
	-- @return mixed
	function Storage:addById(object, id, reload)

		local obj = self:getById(id)
		if obj and not reload then return id, obj
		elseif obj then self:remove(obj) end

		self.list[id] = object
		self.map[object] = id

		self.count = self.count + 1
		return id, object
	end

	--- Remove object from storage
	-- @param mixed object
	-- @return boolean
	function Storage:remove(object)
		local id = self.map[object]
		if not id then return false end
		self.list[id] = nil
		self.map[object] = nil
		if id == self.length then
			self.length = self.length - 1
		else
			self.free[#self.free + 1] = id
		end
		return true
	end

	--- Remove object from storage by Id
	-- @param number id
	-- @return boolean
	function Storage:removeById(id)
		if not self.list[id] then return false end
		self.map[self.list[id]] = nil
		self.list[id] = nil
		if id == self.length then
			self.length = self.length - 1
		else
			self.free[#self.free + 1] = id
		end
		return true
	end

	--- Return object from storage by id
	-- @param number id
	-- @return mixed
	function Storage:getById(id)
		return self.list[id] or false
	end

	--- Checks for object in storage
	-- @param mixed object
	-- @return boolean
	function Storage:has(object)
		return self.map[object] or false
	end

	--- Enumerate storage data #1
	-- @param boolean skipNil
	-- @return function
	function Storage:enum(skipNil)
		local id = 0
		return function ()
			while id < self.length do
				id = id + 1
				if not skipNil or self.list[id] ~= nil then
					return id, self.list[id]
				end
			end
			return nil
		end
	end

	--- Enumerate storage data #2
	-- @param boolean skipNil
	-- @return function
	function Storage:pairs(skipNil)
		local index, object
		return function ()
			index, object = next(self.list, index)
			if not skipNil or object ~= nil then
				return index, object
			end
		end
	end

	--- Get first stored element
	-- @return mixed
	function Storage:first()
		for i = 1, self.length do
			if self.list[i] then return self.list[i] end
		end
		return false
	end

	--- Get last stored element
	-- @return mixed
	function Storage:last()
		return self.list[self.length] or false
	end

return Storage