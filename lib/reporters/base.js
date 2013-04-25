// Generated by CoffeeScript 1.6.1
(function() {
  var BaseReporter, EventEmitter, Runner,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  EventEmitter = require("events").EventEmitter;

  Runner = require("../runner");

  /*
  Base class for reporters
  */


  module.exports = BaseReporter = (function(_super) {

    __extends(BaseReporter, _super);

    /*
    Create and optionally initialize the reporter
    */


    function BaseReporter() {
      this.startTime = null;
      this.endTime = null;
      this.useColors = true;
    }

    /*
    Default color map
    */


    BaseReporter.prototype.colors = {
      'pass': 90,
      'fail': 31,
      'bright pass': 92,
      'bright fail': 91,
      'bright yellow': 93,
      'pending': 36,
      'suite': 0,
      'error title': 0,
      'error message': 31,
      'error stack': 90,
      'checkmark': 32,
      'fast': 90,
      'medium': 33,
      'slow': 31,
      'green': 32,
      'light': 90,
      'diff gutter': 90,
      'diff added': 42,
      'diff removed': 41
    };

    BaseReporter.prototype.symbols = (function() {
      if (process.platform === 'win32') {
        return {
          ok: '\u221A',
          err: '\u00D7',
          dot: '.'
        };
      } else {
        return {
          ok: '✓',
          err: '✖',
          dot: '․'
        };
      }
    })();

    /*
    Colorize a string using a given colour name
    */


    BaseReporter.prototype.color = function(name, str) {
      if (!this.useColors) {
        return str;
      }
      return "\u001b[" + this.colors[name] + "m" + str + "\u001b[0m";
    };

    /*
    The total time (in ms) for all benchmarks
    */


    BaseReporter.prototype.totalTime = function() {
      return this.endTime - this.startTime;
    };

    /*
    Invoked when the runner stars
    */


    BaseReporter.prototype.onStart = function(runner) {
      return this.startTime = Date.now();
    };

    /*
    Invoked when a suite is started
    */


    BaseReporter.prototype.onStartSuite = function(suite) {};

    /*
    Invoked when a suite ends
    */


    BaseReporter.prototype.onCompleteSuite = function(suite) {};

    /*
    Invoked when a benchmark starts
    */


    BaseReporter.prototype.onStartBenchmark = function(suite, benchmark) {};

    /*
    Invoked when a benchmark completes
    */


    BaseReporter.prototype.onCompleteBenchmark = function(suite, benchmark) {};

    /*
    Invoked when all the suites have finished
    */


    BaseReporter.prototype.onComplete = function(suites) {
      return this.endTime = Date.now();
    };

    return BaseReporter;

  })(EventEmitter);

}).call(this);