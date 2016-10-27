
-- node.tree[name1].tree[name2]
-- node(name1)(name2)
-- node/name1/name2

local class = require "mini.class"
local instance = assert(class.instance)

local super = require"memfs.node"
local file = require"memfs.file"
--local table_ordered = require"mini.table.writeorder"

local dir;dir = class("dir", {
	init = function(self, parentdir)
		if super.init then super.init(self) end

		assert(parentdir~=nil, "missing argument")
		assert(parentdir~=false, "invalid argument for new directory")
		assert(self.hardcount)
		self.tree = {} -- table_ordered()
		self:hardlink(".", self)
		self:hardlink("..", parentdir==true and self or parentdir)

		require "mini.class.autometa"(self, dir)
	end
}, assert(super))

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

--[[
function dir:__div(name)
	assert(type(name)=="string", "something wrong, want string got "..type(name))
	--assert(not name:find("/"), "path not supported yet, only direct name")
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
]]--

-- dirgetnode({"a","b"}) <=> dir/"a"/"b"
function dir:getnode(t)
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
