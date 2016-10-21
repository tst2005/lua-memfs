local path = require "memfs.path"

local p = path("/a/b/c.x")
assert( tostring(p) == "/a/b/c.x" )
assert( p:dirname() == "/a/b" )
assert( p:basename() == "c.x" )
assert( p:isabs() == true )

p.sep =';'
assert( p:tostring() == ";a;b;c.x" )
assert( tostring(p)  == ";a;b;c.x" )

p = path(package.path, ';'):insert("END"):insert("BEGIN",1)
assert( p:tostring() == "BEGIN;"..package.path..";END" )

--print(p:concat('\n'))

p = path("a;b;c;d;e", ';')
assert(
	p	:insert("",3)
		:ifinsert("empty -->", p:search("", 0) or false)
		:ifinsert("<-- empty", p:search("", 1) or false)
		:tostring()
	== "a;b;empty -->;;<-- empty;c;d;e"
)

p = path("a;b;c;d;e", ';')
assert(
	p	:ifinsert("empty -->", p:search("", 0) or false)
		:ifinsert("<-- empty", p:search("", 1) or false)
		:tostring()
	== "a;b;c;d;e"
)

print("OK")
