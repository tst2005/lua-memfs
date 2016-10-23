local node = require "memfs.node"

local n0 = require"mini.class".instance(node)


assert(n0.hardlink)
assert(n0.isfile)
assert(n0.isdir)
assert(n0.hardlink)
assert(n0.unhardlink)
assert(n0.all)

print("OK")
