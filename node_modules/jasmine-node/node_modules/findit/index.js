var fs = require('fs');
var path = require('path');
var EventEmitter = require('events').EventEmitter;
var Seq = require('seq');

function createInodeChecker() {
    var inodes = {};
    return function inodeSeen(inode) {
        if (inodes[inode]) {
            return true;
        } else {
            inodes[inode] = true;
            return false;
        }
    }
}

exports = module.exports = find;
exports.find = find;
function find (base, options, cb) {
    cb = arguments[arguments.length - 1];
    if (typeof(cb) !== 'function') {
        cb = undefined;
    }
    var em = new EventEmitter;
    var inodeSeen = createInodeChecker();
    
    function finder (dir, f) {
        Seq()
            .seq(fs.readdir, dir, Seq)
            .flatten()
            .seqEach(function (file) {
                var p = dir + '/' + file;
                fs.lstat(p, this.into(p));
            })
            .seq(function () {
                this(null, Object.keys(this.vars));
            })
            .flatten()
            .seqEach(function (file) {
                var stat = this.vars[file];
                if (cb) cb(file, stat);
                
                if (inodeSeen(stat.ino)) {
                    // already seen this inode, probably a recursive symlink
                    this(null);
                }
                else {
                    em.emit('path', file, stat);
                    
                    if (stat.isSymbolicLink()) {
                        em.emit('link', file, stat);
                        if (options && options.follow_symlinks) {
                          path.exists(file, function(exists) {
                            if (exists) {
                              fs.readlink(file, function(err, resolvedPath) {
                                if (err) {
                                  em.emit('error', err);
                                } else {
                                  finder(path.resolve(path.dir(file), resolvedPath));
                                }
                              });
                            }
                          });
                        } else {
                          this(null);
                        }
                    }
                    else if (stat.isDirectory()) {
                        em.emit('directory', file, stat);
                        finder(file, this);
                    }
                    else {
                        em.emit('file', file, stat);
                        this(null);
                    }
                }
            })
            .seq(f.bind({}, null))
            .catch(em.emit.bind(em, 'error'))
        ;
    }
    
    fs.lstat(base, function (err, s) {
        if (err) {
            em.emit('error', err);
        }
        if (s.isDirectory()) {
            finder(base, em.emit.bind(em, 'end'));
        }
        else if (s.isSymbolicLink()) {
            if (cb) cb(base, s);
            em.emit('link', base, s);
            em.emit('end');
        }
        else {
            if (cb) cb(base, s);
            em.emit('file', base, s);
            em.emit('end');
        }
    });
    
    return em;
};

exports.findSync = function findSync(dir, options, callback) {
    cb = arguments[arguments.length - 1];
    if (typeof(cb) !== 'function') {
        cb = undefined;
    }
    var inodeSeen = createInodeChecker();
    var files = [];
    var fileQueue = [];
    var processFile = function processFile(file) {
        var stat = fs.lstatSync(file);
        if (inodeSeen(stat.ino)) {
            return;
        }
        files.push(file);
        cb && cb(file, stat)
        if (stat.isDirectory()) {
            fs.readdirSync(file).forEach(function(f) { fileQueue.push(path.join(file, f)); });
        } else if (stat.isSymbolicLink()) {
            if (options && options.follow_symlinks && path.existsSync(file)) {
                fileQueue.push(fs.realpathSync(file));
            }
        }
    };
    /* we don't include the starting directory unless it is a file */
    var stat = fs.lstatSync(dir);
    if (stat.isDirectory()) {
        fs.readdirSync(dir).forEach(function(f) { fileQueue.push(path.join(dir, f)); });
    } else {
        fileQueue.push(dir);
    }
    while (fileQueue.length > 0) {
        processFile(fileQueue.shift());
    }
    return files;
};

exports.find.sync = exports.findSync;
