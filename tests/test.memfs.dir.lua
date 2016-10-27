local dir = require "memfs.dir"

local d = dir(true)
d:mkdir("a"):mkdir("aa") --:all(print)

assert(d/"a"/"aa")

local d2 = dir(true)
assert(not pcall(function() d:hardlink("d2", d2) end))

assert(d/"a"/"aa" == d:getnode{"a", "aa"})

print("OK")
