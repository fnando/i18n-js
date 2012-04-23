var assert = require('assert');
var path = require('path');
var findit = require('../');

var to = setTimeout(function () {
    assert.fail('never ended');
}, 5000);

function find_helper(dir, options, callback) {
    var symlinks = [];
    var files = [];
    var dirs = [];

    var finder = findit.find(dir, options);

    finder.on('link', function (link, stat) {
        assert.ok(stat.isSymbolicLink());
        symlinks.push(path.basename(link));
    });

    finder.on('file', function (file, stat) {
        assert.ok(stat.isFile());
        files.push(path.basename(file));
    });

    finder.on('directory', function (dir, stat) {
        assert.ok(stat.isDirectory());
        dirs.push(path.basename(dir));
    });

    finder.on('error', function (err) {
        assert.fail(err);
    });

    finder.on('end', function () {
        clearTimeout(to);

        symlinks.sort();
        files.sort();
        dirs.sort();

        callback({ symlinks: symlinks, files: files, dirs: dirs });
    });
}

exports.links = function() {
    find_helper(__dirname + '/symlinks/dir1', { follow_symlinks: false }, function(data) {
        assert.eql(['dangling-symlink', 'link-to-dir2', 'link-to-file'], data.symlinks);
        assert.eql(['file1'], data.files);
        assert.eql([], data.dirs);
    });
};

exports.follow_links = function() {
    find_helper(__dirname + '/symlinks/dir1', { follow_symlinks: true }, function(data) {
        assert.eql(['cyclic-link-to-dir1', 'dangling-symlink', 'link-to-dir2', 'link-to-file'], data.symlinks);
        assert.eql(['file', 'file1', 'file2'], data.files);
        assert.eql(['dir1', 'dir2'], data.dirs);
    });
};

exports.links_sync = function() {
    var files = findit.findSync(__dirname + '/symlinks/dir1', { follow_symlinks: false }).map(path.basename);
    files.sort();
    assert.eql(['dangling-symlink', 'file1', 'link-to-dir2', 'link-to-file'], files);
};

exports.follow_links_sync = function() {
    var files = findit.findSync(__dirname + '/symlinks/dir1', { follow_symlinks: true }).map(path.basename);
    files.sort();
    assert.eql(['cyclic-link-to-dir1', 'dangling-symlink', 'dir1', 'dir2', 'file', 'file1', 'file2', 'link-to-dir2', 'link-to-file'], files);
};

