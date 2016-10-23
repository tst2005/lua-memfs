


--[[
* node -> file
* node -> dir
 * dir:mkfile()
 * dir:mkdir()
* node -> dir -> fs
]]--

local class = require "mini.class"
local instance = assert(class.instance)

-- new root directory	: node(true)
-- new sub-directory	: node(parentdir)
-- new file		: node(false)

local super = require "memfs.dir"

local rootdir;rootdir = class("rootdir", {
	init = function(self)
		if super.init then super.init(self, true) end
		assert(self.tree)
		assert(self.tree[".."] == self)
		require "mini.class.autometa"(self, rootdir)
	end
}, assert(super))

return setmetatable({}, {__call = function(_, ...) return instance(rootdir, ...) end})
