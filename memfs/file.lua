
local class = require "mini.class"
local instance = assert(class.instance)

local super = require"memfs.node"

local file;file = class("file", {
	init = function(self)
		if super.init then super.init(self) end

		assert(self.hardcount)
		assert(self.isfile and self.isdir and self.hardlink and self.unhardlink)
		assert(not self.tree)

		require "mini.class.autometa"(self, file)
	end
}, assert(super))

function file:destroy() -- __gc ?
	-- nothing to do for file
end

--[[
function file:__div(name)
	assert(type(name)=="string", "something wrong")
	assert(not name:find("/"), "path not supported yet, only direct name")
	return self.tree[name]
end
file.__call = file.__div

function file:__pairs()
	return function()end
end
]]--

return file
