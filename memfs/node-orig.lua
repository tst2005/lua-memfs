
-- node.tree[name1].tree[name2]
-- node(name1)(name2)
-- node/name1/name2

local class = require "mini.class"
local instance = assert(class.instance)

-- new root directory	: node(true)
-- new sub-directory	: node(parentdir)
-- new file		: node(false)

local node;node = class("node", {
	init = function(self, parentdir)
		assert(parentdir~=nil)
		-- common stuff
		self.hardcount = 1
		if parentdir then -- new [root|sub] directory
			self.tree = {}
			self:hardlink(".", self)
			self:hardlink("..", parentdir==true and self or parentdir)
		else -- new file
			--self.tree = nil
		end
		require "mini.class.autometa"(self, node)
	end
})

function node:isfile()
	return not self.tree
end
function node:isdir()
	return not self:isfile()
end

-- create a hardlink of (dir|file)<what> named <name> into (dir)<self>
function node:hardlink(name, what)
	assert(self:isdir())
	assert(not self.tree[name]) -- already exists
	--if not self.tree[name] then
		self.tree[name] = what
		what.hardcount = what.hardcount +1
	--end
end

function node:unhardlink(name)
	local self = self.tree
	if self[name] then
		self[name].hardcount = self[name].hardcount -1
		self[name]=nil
	end
end

function node:mkdir(name)
	if self.tree[name] then
		error("already exists", 2)
	end
	local d = node(self)
	self.tree[name] = d
	return d
end

-- create a new file named <named> into (dir)<self>
function node:mkfile(name)
	if self:isdir() then
		local f = class_file(false)
	end
end

function node:rmdir(name)
	if not self.tree[name] then
		error("not exists", 2)
	end
	self.tree[name]:destroy()
	self.tree[name] = nil
	return nil
end

function node:destroy() -- __gc ?
	if self:isfile() then
		-- nothing to do for file
	else
		self:unhardlink("..")
		self:unhardlink(".") -- useless ?
		assert(self.hardcount == 1)
	end
end

function node:all(f, ...)
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

function node:__div(name)
	assert(type(name)=="string", "something wrong")
	assert(not name:find("/"), "path not supported yet, only direct name")
	return self.tree[name]
end

node.__call = node.__div

function node:__pairs()
	if self:isfile() then
		return function()end
	else
		return pairs(self.tree)
	end
end

return setmetatable({}, {__call = function(_, ...) return instance(node, ...) end})
