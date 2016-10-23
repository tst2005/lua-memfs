
--[[
* node -> file
* node -> dir
 * dir:mkfile()
 * dir:mkdir()
* node -> dir -> rootdir
]]--
-- new root directory	: `rootdir()`	will internaly call `dir(true)`
-- new sub-directory	: `dir(parentdir)`
-- new file		: `file()`

local class = require "mini.class"
local instance = assert(class.instance)

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
