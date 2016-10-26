
--local function tohex(v, len)
--	return ("0x%"..(len and ("0."..len) or "").."x"):format(string.byte(v,1,-1))
--end

local bool = function(x) return not not x end

local class = require "mini.class"
local instance = assert(class.instance)

local rootdir = require "memfs.rootdir"
local newpath = require "memfs.path"
local string_split = require "mini.string.split"

local fs;fs = class("fs", {
	init = function(self, sep, fullfs)
		self._sep = sep or '/'
		self._curpath = newpath(self._sep, self._sep)	-- initial pwd is '/'

		self._rootdir = fullfs or instance(rootdir)	-- import or create a new FS
		self._chroot = self._rootdir			-- by default, there is not chroot, the chroot is the root FS directory
		self._curdir = self._rootdir			-- the initial pwd is the root FS directory

		require "mini.class.autometa"(self, fs)
	end,
})

assert(not fs._newpath)
function fs:_newpath(s)
	return newpath(s, self._sep)
end

assert(not fs.currentdir)
function fs:currentdir()
	return tostring(self._curpath)
end
assert(not fs.pwd)
fs.pwd = fs.currentdir

--[[
-- fs:_getnode {"a","b","c"} <=> fs/"a"/"b"/"c"
function fs:_getnode(t)
	if type(t) == "string" then
		t = {t}
	end
	assert(type(t)=="table", "argument must be a table")
        local cur = self.chroot
        for i, name in ipairs(t) do
	        assert(type(name)=="string", "something wrong, want string got "..type(name))
	        assert(not name:find(self._sep, true), "name must not contains directory separator")
                if name ~= "" then
                        local try
			if (name == ".." and cur == self._chroot) then -- chroot stuff
				try = cur -- do not go outside the chroot !
			elseif not cur.tree then
				return false, i, "not a directory"
			else
                        	try = cur.tree[name]
			end
                        if not try then
                                return false, i, "no such file/directory"
                        end
                        cur=try
                end
        end
        return cur
end
-- fs/"a"/"b"/"c" <=> fs:_getnode {"a","b","c"} <=> fs/{"a","b","c"}
fs.__div = fs._getnode
]]--

assert(not fs._exists)
-- fs:_exists(<s_path>)  <s_path> should be absolute or relative to self._curpath
function fs:_exists(s_path)
	-- solution 1: Always resolve an absolute path from the chrootdir

	-- parse the path (got an absolute or relative path)
	local abs_path = newpath(s_path, self._sep):toabs(self._curpath, true) -- convert it to an absolute path (if not already the case)
	assert(abs_path:isabs())

	-- recursively move on each abs_path's directories
	assert(type(abs_path.path)=="table")
	local node, i, msg = self._chroot:getnode(abs_path.path) -- self._chroot/abs_path.path
	if not node then -- if fail
		-- show the path until the failed part
		return nil, abs_path:concat(abs_path.sep, 1, assert(type(i)=="number" and i)), msg
	end
	return node -- if success then return the targeted object
end
--	-- resolv the path from the current directory (self._curdir) or from the chroot directory
--	local cur
--	if not o_path:isabs() then
--		cur = self._chroot -- absolute path will be resolved from the chrooted directory
--		abs_o_path = o_path
--	else
--		 -- relative path will be resolved from the current directory
--		-- resolve the wanted path to an absolute path
--	end

assert(not fs._setchroot)
function fs:_setchroot(newroot)
	self._chroot = assert(newroot)
	self._curdir = assert(newroot)
	self._curpath = newpath(self._sep, self._sep)
end

assert(not fs.chroot)
function fs:chroot(s_path)
	local ok, err = self:chdir(s_path)
	if not ok then
		return nil, "can not chdir to"..err
	end
	self:_setchroot(self._curdir)
	return true
end

function fs:chdir(s_path)
	local node, err = self:_exists(s_path)
	if not node then
		return nil, "no such directory: "..err
	end
	if not node:isdir() or node:isfile() then -- FIXME: take care about symlink to directory!
		return nil, "path is not a directory: "..s_path
	end
	self._curdir = assert(node)
	return true
end

--function fs:__div(path)
--	return self:cd(path)
--end

function fs:mkdir(s_path)
	local o_path = self:_newpath(s_path, self._sep)
	local node, err = self:_exists(o_path:dirname())
	local name = o_path:basename()
	assert(name~="." and name~="..")
	local ok, err = pcall(function() return node:mkdir(name) end)
	if not ok then return nil, err end
	return true
end

return setmetatable({}, {__call = function(_, ...) return instance(fs, ...) end})

--[=[
lfs.currentdir()
lfs.chdir(path)
lfs.mkdir(dirname)
lfs.rmdir(dirname)


lfs.attributes (filepath [, aname | atable])
dev
ino
mode
nlink
uid
gid
rdev
access
modification
change
size
permissions
blocks
blksize

fs.symlinkattributes(filepath [, aname])

liter, dir_obj = lfs.dir(path)
function fs:__pairs()
        if self:isfile() then
                return function()end
        else
                return pairs(self.tree) -- /!\ chroot evasion ?
        end
end

lfs.link(old, new[, symlink])
lfs.setmode(file, mode)
lfs.touch(filepath [, atime [, mtime] ])

lfs.lock(filehandle, mode[, start[, length] ])
lfs.lock_dir(path, [seconds_stale])
lfs.unlock(filehandle[, start[, length]])
]=]--

--[[
fs.mkdir = function(dir)
fs.rmdir = function(dir, recursive)  -- /!\ refuse to remove "." or ".."

fs.copy = function(fromfile, tofile)
fs.move = function(fromfile, tofile)
fs.rename = function(file, newname)

fs.create = function(file)
fs.remove = function(file) -- /!\ enforce check of node type, do not remove ".." (chroot evasion?)

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


--[[
local function read_header_block(block)
	local funcs = {}										    -- SIZE
	funcs.rawname		= function(self) return nullterm(block:sub(1,100))			end -- 100
	funcs.name		= funcs.rawname

	funcs.mode		= function(self) return nullterm(block:sub(101,108))			end -- 8
	funcs.uid		= function(self) return octal_to_number(nullterm(block:sub(109,116)))	end -- 16
	funcs.gid		= function(self) return octal_to_number(nullterm(block:sub(117,124)))	end -- 8
	funcs.size		= function(self) return octal_to_number(nullterm(block:sub(125,136)))	end -- 12
	funcs.mtime		= function(self) return octal_to_number(nullterm(block:sub(137,148)))	end -- 12
	funcs.chksum		= function(self) return octal_to_number(nullterm(block:sub(149,156)))	end -- 8
	funcs.rawtypeflag	= function(self) return block:sub(157,157)				end -- 1
	funcs.typeflag		= function(self) return get_typeflag(self.rawtypeflag())			end
	funcs.linkname		= function(self) return nullterm(block:sub(158,257))			end -- 100
	funcs.magic		= function(self) return block:sub(258,263)				end -- 6
	funcs.version		= function(self) return block:sub(264,265)				end -- 2
	funcs.uname		= function(self) return nullterm(block:sub(266,297))			end -- 32
	funcs.gname		= function(self) return nullterm(block:sub(298,329))			end -- 32
	funcs.devmajor		= function(self) return octal_to_number(nullterm(block:sub(330,337)))	end -- 8
	funcs.devminor		= function(self) return octal_to_number(nullterm(block:sub(338,345)))	end -- 8
	funcs.prefix		= function(self) return block:sub(346,500)				end -- 155

	local header = setmetatable({}, {__index=function(_,k) return assert(funcs[k], "invalid field")(funcs) end})

	return header
end
-- a////b => a/b
-- a/./b  => a/b
-- a/x/../b => a/b
-- x/../a/b => a/b

function fs:cleanpath(path)
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
