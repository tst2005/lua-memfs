local dir = require "memfs.dir"

local d = dir(true)
d:mkdir("a"):mkdir("aa"):all(rprint)

print("OK")
