var assert = require('assert');
var traverse = require('../');

exports.has = function () {
    var obj = { a : 2, b : [ 4, 5, { c : 6 } ] };
    
    assert.equal(traverse(obj).has([ 'b', 2, 'c' ]), true)
    assert.equal(traverse(obj).has([ 'b', 2, 'c', 0 ]), false)
    assert.equal(traverse(obj).has([ 'b', 2, 'd' ]), false)
    assert.equal(traverse(obj).has([]), true)
    assert.equal(traverse(obj).has([ 'a' ]), true)
    assert.equal(traverse(obj).has([ 'a', 2 ]), false)
};
