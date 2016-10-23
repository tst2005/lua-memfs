
local string_split = require "mini.string.split"

local class = require "mini.class"
local instance = assert(class.instance)

local class_path;class_path = class("path", {
	init = function(self, p, sep)
		self.sep = sep or '/'
		self.path = string_split(p or ".", self.sep)
		require "mini.class.autometa"(self, class_path)
	end
})

function class_path:chsep(newsep)
	self.sep = assert(newsep) -- FIXME: check if items contains newsep ?
	return self
end
function class_path:insert(what, where)
	if where == false then return self end
	assert(type(what)=="string")
	if not where then
		where = (#self.path+1)
	elseif where <= -1 then
		where = #self.path +where +2
	elseif where < 1 then
		where = 1
	end
	table.insert(self.path, where, what)
	return self
end
function class_path:search(item, offset)
	for i,v in ipairs(self.path) do
		if v == item then
			return i+(offset or 0)
		end
	end
	return nil
end
function class_path:ifinsert(what, where, found_offset)
	if where == false then return self end
	local i = self:search(what, found_offset)
	if i then
		return self
	end
	where = where or found_offset and i
	return self:insert(what or what_search, where)
end

function class_path:dirname()
	return table.concat(self.path, self.sep, 1, #self.path-1)
end
function class_path:basename(ext)
	assert(not ext, "basename: ext is not implemented yet")
	return self.path[#self.path]
end

function class_path:join(path2)
	error("TODO: not implemented yet")
	assert(self.sep == path2.sep)
	return instance(class_path, tostring(self)..self.sep..tostring(path2), self.sep)
end

function class_path:isabs()
	return self.path[1]==""
end

function class_path:__tostring()
	return table.concat(self.path, self.sep)
end

class_path.tostring = class_path.__tostring


function class_path:concat(sep, i, j)
	sep = sep or self.sep
	return table.concat(self.path, sep, i, j)
end
	

-- a////b => a/b
-- a/./b  => a/b
-- a/x/../b => a/b (disabled)
-- x/../a/b => a/b (disabled)
--[[
function class_path:normpath(path)
	local sep = self.sep
	assert(sep == "/", "separator is not supported")
	return (
		path
		:gsub("^$", ".")		-- if empty returns "."
		:gsub("/+", "/")		-- remove multiple '/' occurrence
		:gsub("/$", "")			-- remove ending '/' if exists
		:gsub("$", "/")			-- add ending '/'
		:gsub("/%./", "/")
--			:gsub("^", "/")			-- prefix by '/'
--			:gsub("/[^/]+/%.%./", "/")	-- reduce "/something/.." to "/"
--			:gsub("^/", "")			-- remove the '/' prefix
		:gsub("^(.+)/$", "%1")		-- remove the last ending '/' if exists
		:gsub("^%./(.+)$", "%1")	-- if "./something" keep "something"
	)
end
]]--

--[[
fs.mkdir = function(dir)
fs.rmdir = function(dir, recursive)

fs.copy = function(fromfile, tofile)
fs.move = function(fromfile, tofile)
fs.rename = function(file, newname)

fs.create = function(file)
fs.remove = function(file)

fs.write = function(file, data)
fs.append = function(file, data)
-- fs.touch => fs.append(file, "") ou fs.update(file, now(), now()) ?
fs.read = function(file)

fs.appendcopy = function(fromfile, tofile)
fs.appendmove = function(fromfile, tofile)
fs.update = function(file, accesstime, modificationtime)

-- file meta info
fs.size = function(file)
fs.permissions = function(file)
fs.device = function(file)
fs.type = function(file)
fs.uid = function(file)
fs.gid = function(file)
fs.accesstime = function(file)		-- getatime
fs.modificationtime = function(file)	-- getmtime
fs.changetime = function(file)		-- getctime

fs.tmpname = function(length, prefix, suffix)
fs.files = function(dir, fullpath)

fs.link = function(file, link)		-- link
-- missing: unlink
fs.symlink = function(file, link)

fs.usetmp = function(length, prefix, suffix, call, dir)
fs.usetmpdir = function(length, prefix, suffix, call)

fs.separator = function()	-- dirsep
--fs.system = function(unixtype) -- os.arch ?
]]--

return setmetatable({}, {__call = function(_, ...) return instance(class_path, ...) end})
