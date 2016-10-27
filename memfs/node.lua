
local class = require "mini.class"
local instance = assert(class.instance)

local node;node = class("node", {
	init = function(self)
		self.hardcount = 1
		require "mini.class.autometa"(self, node)
	end
})
--[[
local node = class("node")
function node:init()
	self.hardcount = 1
	require "mini.class.autometa"(self, node)
end
]]--

function node:isfile()
	return not self.tree
end
function node:isdir()
	return not self:isfile()
end

-- create a hardlink of a (file)<what> named <name> into (dir)<self>
function node:hardlink(name, what)
	assert(self:isdir(), "must be a directory")
	assert(name=="." or name==".." or what:isfile(), "only hardlink of file is supported")
	if self.tree[name] then -- already exists
		return nil
	end
	self.tree[name] = what
	what.hardcount = what.hardcount +1
	return true	
end

-- create a [hard]link of (file)<self> in (dir)<where>/<name>
function node:link(where, name, symlink)
	assert(symlink==nil, "symlink not yet implemented")

	assert(where:isdir(), "must be a directory")
	assert(name=="." or name==".." or what:isfile(), "only hardlink of file is supported")
	if where/name then -- already exists
		return nil, "already exists"
	end
	where.tree[name] = self
	self.hardcount = self.hardcount +1
	return true
end

function node:unhardlink(name)
	if not self.tree[name] then
		return nil
	end
	self.tree[name].hardcount = self.tree[name].hardcount -1
	self.tree[name]=nil
	return true
end

function node:all(f, ...)
	if self:isfile() then -- self is a file, do ... nothing?
		--f(...)
		return
	end
--[[
local function rprint(k,v, pdir)
        printdir(k,v,pdir)
        if type(v)=="table" and k~="." and k~=".." then
                v:all(rprint, pdir.."/"..k)
        end
end
]]--
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

-- node:getnode{"a","b","c"} <=> node/"a"/"b"/"c"
function node:getnode(t)
	if type(t) == "string" then
		t = {t}
	end
	assert(type(t)=="table", "argument must be a table")
        local cur = self
        for i, name in ipairs(t) do
	        assert(type(name)=="string", "something wrong, want string got "..type(name))
                if name ~= "" then
			if not cur.tree then
				return false, i, "not a directory"
			end
                        local try = cur.tree[name]
                        if not try then
                                return false, i, "no such file/directory"
                        end
                        cur=try
                end
        end
        return cur
end
-- node/"a"/"b"/"c" <=> node:getnode {"a","b","c"} <=> node/{"a","b","c"}
node.__div = assert(node.getnode)

--[[
function node:__pairs()
	if self:isfile() then
		return function()end
	else
		return pairs(self.tree)
	end
end
]]--

return node
