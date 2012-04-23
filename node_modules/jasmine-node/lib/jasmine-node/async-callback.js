(function() {
  var withoutAsync = {};

  ["it", "beforeEach", "afterEach"].forEach(function(jasmineFunction) {
    withoutAsync[jasmineFunction] = jasmine.Env.prototype[jasmineFunction];
    return jasmine.Env.prototype[jasmineFunction] = function() {
      var args = Array.prototype.slice.call(arguments, 0);
      var specFunction = args.pop();
      if (specFunction.length === 0) {
        args.push(specFunction);
      } else {
        args.push(function() {
          return asyncSpec(specFunction, this);
        });
      }
      return withoutAsync[jasmineFunction].apply(this, args);
    };
  });

  function asyncSpec(specFunction, spec, timeout) {
    if (timeout == null) timeout = 1000;
    var done = false;
    spec.runs(function() {
      try {
        return specFunction(function(error) {
          done = true;
          if (error != null) return spec.fail(error);
        });
      } catch (e) {
        done = true;
        throw e;
      }
    });
    return spec.waitsFor(function() {
      if (done === true) {
        return true;
      }
    }, "spec to complete", timeout);
  };

}).call(this);
