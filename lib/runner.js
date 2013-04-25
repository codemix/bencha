// Generated by CoffeeScript 1.6.1
(function() {
  var Benchmark, EventEmitter, History, Runner, SpecReporter,
    _this = this,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  EventEmitter = require("events").EventEmitter;

  Benchmark = require("benchmark");

  SpecReporter = require("./reporters/spec");

  History = require("./history");

  /*
  The main test runner
  */


  module.exports = Runner = (function(_super) {

    __extends(Runner, _super);

    /*
    Set the initial values for the runner
    */


    function Runner(config) {
      var _this = this;
      this.runWithGlobals = function(suite, fn) {
        return Runner.prototype.runWithGlobals.apply(_this, arguments);
      };
      this.bindToSuite = function(suite) {
        return Runner.prototype.bindToSuite.apply(_this, arguments);
      };
      this.addComparison = function(name, fn) {
        return Runner.prototype.addComparison.apply(_this, arguments);
      };
      this.addSuite = function(name, fn) {
        return Runner.prototype.addSuite.apply(_this, arguments);
      };
      this.complete = function() {
        return Runner.prototype.complete.apply(_this, arguments);
      };
      this.runNext = function() {
        return Runner.prototype.runNext.apply(_this, arguments);
      };
      this.run = function() {
        return Runner.prototype.run.apply(_this, arguments);
      };
      this.configure(this.defaults());
      if (config) {
        this.configure(config);
      }
      if (this.autoInit) {
        this.init();
      }
    }

    /*
    Default properties for benchmark runners
    */


    Runner.prototype.defaults = function() {
      return {
        index: -1,
        suites: [],
        initialized: false,
        skip: [],
        only: [],
        autoInit: true,
        tag: null,
        reporter: new SpecReporter(),
        historyFilename: "history.json",
        history: new History
      };
    };

    /*
    Configure the runner based on an object
    */


    Runner.prototype.configure = function(config) {
      var key, value;
      for (key in config) {
        value = config[key];
        this[key] = value;
      }
      return this;
    };

    /*
    Initialize the runner
    */


    Runner.prototype.init = function() {
      var _this = this;
      this.restore = {
        compare: global.compare,
        suite: global.suite
      };
      global.compare = this.addComparison;
      global.suite = this.addSuite;
      global.compare.only = function(name, body) {
        _this.only.push(name);
        return global.compare(name, body);
      };
      global.compare.skip = function(name, body) {
        _this.skip.push(name);
        return global.compare(name, body);
      };
      global.suite.only = function(name, body) {
        _this.only.push(name);
        return global.suite(name, body);
      };
      global.suite.skip = function(name, body) {
        _this.skip.push(name);
        return global.suite(name, body);
      };
      return this.initialized = true;
    };

    /*
    Destroy the runner
    */


    Runner.prototype.destroy = function() {
      global.compare = this.restore.compare;
      global.suite = this.restore.suite;
      return this.initialized = false;
    };

    /*
    Run the benchmarks
    */


    Runner.prototype.run = function() {
      var completed, run,
        _this = this;
      completed = function(suites) {
        _this.removeListener("start-suite", _this.reporter.onStartSuite);
        _this.removeListener("start-benchmark", _this.reporter.onStartBenchmark);
        _this.removeListener("complete-benchmark", _this.reporter.onCompleteBenchmark);
        _this.removeListener("complete-suite", _this.reporter.onCompleteSuite);
        return _this.reporter.onComplete(suites);
      };
      run = function() {
        _this.reporter.runner = _this;
        _this.reporter.onStart(_this.suites);
        _this.on("start-suite", _this.reporter.onStartSuite);
        _this.on("start-benchmark", _this.reporter.onStartBenchmark);
        _this.on("complete-benchmark", _this.reporter.onCompleteBenchmark);
        _this.on("complete-suite", _this.reporter.onCompleteSuite);
        _this.on("complete", function(suites) {
          if (_this.history != null) {
            _this.history.addRun(_this.tag, new Date, suites);
            return _this.history.save(_this.historyFilename, function(err) {
              if (err) {
                throw err;
              }
              return completed(suites);
            });
          } else {
            return completed(suites);
          }
        });
        _this.index = -1;
        return _this.runNext();
      };
      if (this.history) {
        return this.history.load(this.historyFilename, run);
      } else {
        return run();
      }
    };

    /*
    Run the next benchmark, or complete if finished
    */


    Runner.prototype.runNext = function() {
      var suite;
      this.index += 1;
      suite = this.suites[this.index];
      if (suite == null) {
        return this.complete();
      }
      if (~this.skip.indexOf(suite.name)) {
        this.emit("skip-suite");
        return this.runNext();
      }
      if (this.only.length && !~this.only.indexOf(suite.name)) {
        return this.runNext();
      }
      return suite.run({
        async: true
      });
    };

    /*
    Invoked when the tests complete
    */


    Runner.prototype.complete = function() {
      return this.emit("complete", this.suites);
    };

    /*
    Add a named benchmark suite
    */


    Runner.prototype.addSuite = function(name, fn) {
      var suite;
      suite = new Benchmark.Suite(name);
      this.runWithGlobals(suite, fn);
      this.bindToSuite(suite);
      this.suites.push(suite);
      return this;
    };

    /*
    Add a named comparison suite
    */


    Runner.prototype.addComparison = function(name, fn) {
      var suite;
      suite = new Benchmark.Suite(name);
      suite.isComparison = true;
      this.runWithGlobals(suite, fn);
      this.bindToSuite(suite);
      this.suites.push(suite);
      return this;
    };

    /*
    Bind to suite events
    */


    Runner.prototype.bindToSuite = function(suite) {
      var _this = this;
      suite.on('start', function() {
        return _this.emit('start-suite', suite);
      });
      suite.on('complete', function() {
        _this.emit('complete-suite', suite);
        return _this.runNext();
      });
      return suite;
    };

    /*
    Run the given function with the global helper methods available
    */


    Runner.prototype.runWithGlobals = function(suite, fn) {
      var restore, result,
        _this = this;
      restore = {
        before: global.before,
        after: global.after,
        benchmark: global.benchmark
      };
      global.before = function(callback) {
        return suite.on('start', callback);
      };
      global.after = function(callback) {
        return suite.on('complete', callback);
      };
      global.benchmark = function(name, bench) {
        var opts, wrapped;
        opts = {
          onStart: function(event) {
            return _this.emit('start-benchmark', suite, event.target);
          },
          onComplete: function(event) {
            return _this.emit('complete-benchmark', suite, event.target);
          }
        };
        if (bench.length) {
          opts.defer = true;
          wrapped = function(deferred) {
            return bench(function() {
              return deferred.resolve();
            });
          };
        } else {
          wrapped = bench;
        }
        return suite.add(name, wrapped, opts);
      };
      result = fn();
      global.before = restore.before;
      global.after = restore.after;
      global.benchmark = restore.benchmark;
      return result;
    };

    return Runner;

  })(EventEmitter);

}).call(this);