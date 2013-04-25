// Generated by CoffeeScript 1.6.1
(function() {
  var Runner, exec, loadTag, optimist, path, reporters, run;

  optimist = require("optimist");

  require("coffee-script");

  path = require("path");

  Runner = require("./runner");

  reporters = require("./reporters");

  exec = require("child_process").exec;

  run = function(argv) {
    var fn;
    if (argv == null) {
      argv = process.argv;
    }
    argv = optimist(argv).argv;
    fn = function(tag) {
      var dir, historyFilename, reporterName, runner;
      dir = argv.dir || path.join(process.cwd(), "bench");
      historyFilename = argv.history || path.join(process.cwd(), "bench", "history.json");
      reporterName = argv.reporter || "spec";
      runner = new Runner({
        historyFilename: historyFilename,
        reporter: new reporters[reporterName],
        tag: tag
      });
      require(dir);
      return runner.run();
    };
    if (argv.tag) {
      return fn(tag);
    } else if (argv.vcs) {
      return loadTag(argv.vcs, function(err, tag) {
        if (err) {
          throw err;
        }
        return fn(tag);
      });
    } else {
      return loadTag("git", function(err, tag) {
        if (err) {
          tag = String(new Date);
        }
        return fn(tag);
      });
    }
  };

  loadTag = function(type, callback) {
    if (type == null) {
      type = "git";
    }
    switch (type) {
      case "git":
        return exec("git rev-parse HEAD", function(err, tag) {
          return callback(err, String(tag).trim());
        });
    }
  };

  /*
  Bencha command line interface
  */


  module.exports = {
    run: run
  };

}).call(this);