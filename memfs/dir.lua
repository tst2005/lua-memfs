
-- node.tree[name1].tree[name2]
-- node(name1)(name2)
-- node/name1/name2

local class = require "mini.class"
local instance = assert(class.instance)

-- new root directory	: node(true)
-- new sub-directory	: node(parentdir)
-- new file		: node(false)

local super = require"memfs.node"
local file = require"memfs.file"

local dir;dir = class("dir", {
	init = function(self, parentdir)
		if super.init then super.init(self) end

		assert(parentdir~=nil, "missing argument")
		assert(parentdir~=false, "invalid argument for new directory")
		assert(self.hardcount)
		self.tree = {}
		self:hardlink(".", self)
		self:hardlink("..", parentdir==true and self or parentdir)

		require "mini.class.autometa"(self, dir)
	end
}, assert(super))

--[[
-- create a hardlink of (dir|file)<what> named <name> into (dir)<self>
function dir:hardlink(name, what)
	assert(self:isdir())
	assert(self.tree[name]) -- already exists
	--if not self.tree[name] then
		self.tree[name] = what
		what.hardcount = what.hardcount +1
	--end
end
assert(not super.hardlink)
function dir:unhardlink(name)
	local self = self.tree
	if self[name] then
		self[name].hardcount = self[name].hardcount -1
		self[name]=nil
	end
end
assert(not super.unhardlink)
]]--

function dir:mkdir(name)
	if self.tree[name] then
		error("already exists", 2)
	end
	local d = instance(dir,self)
	self.tree[name] = d
	return d
end
assert(not super.mkdir)

-- create a new file named <named> into (dir)<self>
function dir:mkfile(name)
	local f = instance(file)
	self.tree[name] = f
	return f
end
assert(not super.mkfile)

function dir:rmdir(name)
	if not self.tree[name] then
		error("not exists", 2)
	end
	self.tree[name]:destroy()
	self.tree[name] = nil
	return nil
end
assert(not super.mkfile)

function dir:destroy() -- __gc ?
	self:unhardlink("..")
	self:unhardlink(".") -- useless ?
	assert(self.hardcount == 1)
end
assert(not super.mkfile)

--[[
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
assert(not super.all)
]]--

function dir:__div(name)
	assert(type(name)=="string", "something wrong")
	assert(not name:find("/"), "path not supported yet, only direct name")
	return self.tree[name]
end
assert(not super.__div)

dir.__call = dir.__div
assert(not super.__call)

function dir:__pairs()
	if self:isfile() then
		return function()end
	else
		return pairs(self.tree)
	end
end
assert(not super.__pairs)

return dir
--return setmetatable({}, {__call = function(_, ...) return instance(dir, ...) end})
