local fs = require "memfs"

local r = fs('/')
assert(r/"." == r and r/".." == r)
local aa = r:mkdir("a"):mkdir("aa")
assert(r/"a"==aa/"..")
assert(aa/"."==aa)


local r0 = fs('/') -- the root directory (usualy asked "/")

local function printdir(k,v, pdir)
	pdir=pdir or ""
	print(v, pdir.."/"..k, (k~="." and k~=".." and v.hardcount or ""))
end
local function rprint(k,v, pdir)
	printdir(k,v,pdir)
	if type(v)=="table" and k~="." and k~=".." then
		v:all(rprint, pdir.."/"..k)
	end
end


r0:mkdir"foo"		-- /foo
r0:mkdir"bar"		-- /bar
r0"bar":mkdir"rrr"	-- /bar/rrr

--[[
assert(r0 "."  == r0)
assert(r0 ".." == r0)

assert(r0 "foo" "."  == r0 "foo")
assert(r0 "foo" ".." == r0)

assert(r0 "bar" "."  == r0 "bar")
assert(r0 "bar" ".." == r0)

assert(r0 "bar" "rrr" "."  == r0 "bar" "rrr")
assert(r0 "bar" "rrr" ".." == r0 "bar")
]]--

--

assert(r0/"."  == r0 ".")
do	local name = "."
	assert(r0/name == r0(name))
end
assert(r0/"."  == r0)
assert(r0/".." == r0)

assert(r0/"foo"/"."  == r0 "foo")
assert(r0/"foo"/".." == r0)

assert(r0/"bar"/"."  == r0 "bar")
assert(r0/"bar"/".." == r0)

assert(r0/"bar"/"rrr"/"."  == r0 "bar" "rrr")
assert(r0/"bar"/"rrr"/".." == r0 "bar")

local f1 = r0:mkfile("f1")
r0:hardlink("f2", f1)
r0:hardlink("f3", f1)
local subdir="foo"
assert(r0/subdir):hardlink("f1x", f1)


r0:all(rprint, "")

assert(r0:exists("/bar/rrr") == true)
print("rmdir rrr")
r0("bar"):rmdir("rrr")
assert(r0:exists("/bar/rrr") == false)

r0:all(rprint, "")

print("OK")
