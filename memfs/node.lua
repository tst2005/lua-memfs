
-- node.tree[name1].tree[name2]
-- node(name1)(name2)
-- node/name1/name2

local class = require "mini.class"
local instance = assert(class.instance)

-- new root directory	: node(true)
-- new sub-directory	: node(parentdir)
-- new file		: node(false)

local node;node = class("node", {
	init = function(self)
		-- common stuff
		self.hardcount = 1
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

--[[
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
]]--

return node
--return setmetatable({node_class=node}, {__call = function(_, ...) return instance(node, ...) end})
