
local class = require "mini.class"
local instance = assert(class.instance)

local super = require"memfs.node"

local file = class("file", nil, assert(super))
function file:init(self)
	if super.init then super.init(self) end

	assert(self._hardcount)
	assert(self.hardcountincr)
	assert(self.isfile and self.isdir and self.hardlink and self.unhardlink)
	assert(not self.tree)

	require "mini.class.autometa"(self, file)
end

function file:destroy() -- __gc ?
	-- nothing to do for file
end

--[[
function file:__div(name) end
file.__call = file.__div
function file:__pairs() end
]]--

return file
