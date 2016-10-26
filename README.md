# lua-memfs

Why ?
=====

 * File-System consideration are as complicated as interested.
 * Lua don't have a standard (full featured) file system abstraction

Goal
====

 * Do a FS !
 * Defined a full featured API
 * bind the API on the true FS (with LFS), over tar file, over sqlite-fs, etc.

More features than expected
===========================

* hardlink : file and directory supported
* shared one file system between multiple sessions
* chroot : (restrict one session to be restricted inside a directory content)
* path separator abstraction (allow to share FS between different path manager (like unix VS windows)
* mount point : attach a root directory to another FS directory

Sample
======

FILLME

License
=======

This project is Under MIT License
