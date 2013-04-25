# Bencha

Mocha-esque UI for the excellent `benchmark.js` JavaScript benchmarking library.
Records benchmark history and flags performance improvements and regressions.

# Installation

    npm install bencha -g

# Writing Benchmarks

Create a `bench` directory in your project. In the `bench` directory, create
an `index.js` (or `index.coffee`), e.g.

    compare("RegExp vs String::indexOf", function(){
      var input = "demo.string"
      benchmark("RegExp", function(){
        /(\.)/.test(input);
      });
      benchmark("String::indexOf", function(){
        input.indexOf(".") > -1;
      });
    });

    suite("My Feature", function(){
      benchmark("foo() no arguments", function(){
        foo();
      });
      benchmark("foo() with arguments", function(){
        foo(true, false);
      });
      benchmark("bar()", function(){
        bar()
      });
    });

The above defines two benchmark suites, the first is a comparison suite, comparison suites compare
the results of each benchmark within the suite, declaring one the winner. The second declaration defines
a suite containing three separate benchmarks that are related but not explicitly compared with each other.

To split your benchmarks into seperate files, simply `require()` them from the main `index.js` file.


# Running Benchmarks

From your project root (or the directory containing the `bench` folder), run:

    bencha

This will run the benchmarks with the default `spec` reporter, recording the results in `bench/history.json`

Run `bencha --help` for more options.


# Licence

MIT

