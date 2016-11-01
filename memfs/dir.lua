
-- node.tree[name1].tree[name2]
-- node(name1)(name2)
-- node/name1/name2

local asserttype = require "mini.asserttype"

local class = require "mini.class"
local instance = assert(class.instance)

local super = require"memfs.node"
local file = require"memfs.file"
local tree = require "memfs.tree"

local dir = class("dir", nil, assert(super))
function dir:init(parentdir)
	if super.init then super.init(self) end

	assert(parentdir~=nil, "missing argument")
	assert(parentdir~=false, "invalid argument for new directory")
	asserttype(self._hardcount, "number")
	asserttype(self.hardcountincr, "function")

	self.tree = tree()

	self:hardlink(".", self)

	if parentdir == true then
		self:becomerootdir()
	elseif parentdir then
		asserttype(parentdir, "table", "invalid parentdir", 2)
		self:link("..", parentdir)
	end

	require "mini.class.autometa"(self, dir)
end

function dir:becomerootdir()
	self:link("..", self)
	return self
end
function dir:isorphan()
	return self.tree[".."]==nil
end
function dir:link(name, item)
	asserttype(name,  "string", "link: invalid directory name",  2)
	asserttype(item, "table",   "link: invalid item", 2)
	if self.tree[name] then
		error("already exists", 2)
	end
	self.tree[name] = item
	item:hardcountincr(1)
end
function dir:unlink(name)
	local item = self.tree[name]
	if not item then
		return nil
	end
	item:hardcountincr(-1)
	self.tree[name] = nil
end

function dir:mkdir(name)
	asserttype(name, "string", "must be a string", 2)
	if self.tree[name] then
		error("already exists", 2)
	end
	local child = instance(dir,self)
	self.tree[name] = child
	return child
end
assert(not super.mkdir)

-- create a new file named <named> into (dir)<self>
function dir:mkfile(name)
	asserttype(name, "string", "must be a string", 2)
	local f = instance(file)
	self.tree[name] = f
	return f
end
assert(not super.mkfile)

function dir:rmdir(name)
	asserttype(name, "string", "must be a string", 2)
	if not self.tree[name] then
		error("not exists", 2)
	end
	self:unhardlink("..")
	--self:unhardlink(".") -- useless ?
	self.tree[name] = nil
	return nil
end
assert(not super.rmdir)

--[[
function dir:destroy() -- __gc ?
	self:unhardlink(".") -- useless ?
	assert(self.hardcount == 1)
end
assert(not super.destroy)
]]--

function dir:__div(name)
	asserttype(name, "string", "something wrong, want string got "..type(name), 2)
	return self.tree[name]
end
assert(not super.__div)

--[[
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
]]--

-- dirgetnode({"a","b"}) <=> dir/"a"/"b"
function dir:getnode(t)
	asserttype(t, "table", "must be a table", 2)
	local cur = self
	for i, name in ipairs(t) do
		if name ~= "" then
			local try = cur/name
			if not try then
				return false, i
			end
			cur=try
		end
	end
	return cur
end

return dir
