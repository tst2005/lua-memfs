local dir = require "memfs.dir"
local r0 = dir(true) -- the root directory (usualy asked "/")

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


r0:all(rprint, "")
print("rmdir rrr")
r0("bar"):rmdir("rrr")
r0:all(rprint, "")

print("OK")
