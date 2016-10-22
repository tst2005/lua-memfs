
-- dir.tree[name1].tree[name2]
-- dir(name1)(name2)

local class = require "mini.class"
local instance = assert(class.instance)

-- new root directory	: dir(true)
-- new sub-directory	: dir(parentdir)
-- new file		: dir(false)

local dir;dir = class("dir", {
	init = function(self, parentdir)
		assert(parentdir~=nil)
		if parentdir then -- new [root|sub] directory
			self.hardcount = 1
			self.tree = {}
			self:hardlink(".", self)
			self:hardlink("..", parentdir==true and self or parentdir)
		else -- new file
			--self.tree = nil
		end
		require "mini.class.autometa"(self, dir)
	end
})

-- create a hardlink of <what> named <name> into <self>
function dir:hardlink(name, what)
	if not self:isfile() and not self.tree[name] then
		self.tree[name] = what
		what.hardcount = what.hardcount +1
	end
end

function dir:unhardlink(name)
	local self = self.tree
	if self[name] then
		self[name].hardcount = self[name].hardcount -1
		self[name]=nil
	end
end

function dir:mkdir(name)
	if self.tree[name] then
		error("already exists", 2)
	end
	local d = dir(self)
	self.tree[name] = d
	return d
end

function dir:rmdir(name)
	if not self.tree[name] then
		error("not exists", 2)
	end
	self.tree[name]:destroy()
	self.tree[name] = nil
	return nil
end

function dir:destroy() -- __gc ?
	if self:isfile() then
		-- nothing to do for file
	else
		self:unhardlink("..")
		self:unhardlink(".") -- useless ?
		assert(self.hardcount == 1)
	end
end

function dir:isfile()
	return not self.tree
end

function dir:all(f, ...)
	if self:isfile() then -- self is a file, do ... nothing?
		--f(...)
		return
	end
	if self.tree["."] then
		f(".", self.tree["."], ...)
	end
	if self.tree[".."] then
		f("..", self.tree[".."], ...)
	end
	for k,v in pairs(self.tree) do
		if k~="." and k~=".." then
			f(k, v, ...)
		end
	end
end

function dir:__div(name)
	assert(type(name)=="string", "something wrong")
	assert(not name:find("/"), "path not supported yet, only direct name")
	return self.tree[name]
end

dir.__call = dir.__div

function dir:__pairs()
	if self:isfile() then
		return function()end
	else
		return pairs(self.tree)
	end
end

return setmetatable({}, {__call = function(_, ...) return instance(dir, ...) end})
