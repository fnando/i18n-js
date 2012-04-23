findit
======

Recursively walk directory trees. Think `/usr/bin/find`.

example time!
=============

callback style
--------------

````javascript
require('findit').find(__dirname, function (file) {
    console.log(file);
})
````

emitter style
-------------

````javascript
var finder = require('findit').find(__dirname);

finder.on('directory', function (dir, stat) {
    console.log(dir + '/');
});

finder.on('file', function (file, stat) {
    console.log(file);
});

finder.on('link', function (link, stat) {
    console.log(link);
});
````

synchronous
-----------

````javascript
var files = require('findit').sync(__dirname);
    console.dir(files);
````

methods
=======

find(basedir, options, cb)
-----------------

Do an asynchronous recursive walk starting at `basedir`.

Optionally supply an options object. Setting the property 'follow_symlinks'
will follow symlinks.

Optionally supply a callback that will get the same arguments as the path event
documented below in "events".

If `basedir` is actually a non-directory regular file, findit emits a single
"file" event for it then emits "end".

Findit uses `fs.lstat()` so symlinks are not traversed automatically. To have it
follow symlinks, supply the options argument with 'follow_symlinks' set to true.
Findit won't traverse an inode that it has seen before so directories can have
symlink cycles and findit won't blow up.

Returns an EventEmitter. See "events".

sync(basedir, options, cb)
-----------------

Return an array of files and directories from a synchronous recursive walk
starting at `basedir`.

Optionally supply an options object. Setting the property 'follow_symlinks'
will follow symlinks.

An optional callback `cb` will get called with `cb(file, stat)` if specified.

events
======

file: [ file, stat ]
--------------------

Emitted for just files which are not directories.

directory : [ directory, stat ]
-------------------------------

Emitted for directories.

path : [ file, stat ]
---------------------

Emitted for both files and directories.

end
---

Emitted when the recursive walk is done.
