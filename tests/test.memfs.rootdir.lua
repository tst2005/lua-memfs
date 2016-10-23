local rootdir = require "memfs.rootdir"

local r = rootdir()
assert(r/"." == r and r/".." == r)
local aa = r:mkdir("a"):mkdir("aa")
assert(r/"a"==aa/"..")
assert(aa/"."==aa)

print("OK")
