local dir = require "memfs.dir"

local d = dir(true)
d:mkdir("a"):mkdir("aa") --:all(print)

assert(d/"a"/"aa" == d:getnode{"a", "aa"})

print("OK")
