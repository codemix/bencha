{EventEmitter} = require "events"
Benchmark = require "benchmark"

SpecReporter = require "./reporters/spec"
History = require "./history"

###
The main test runner
###
module.exports = class Runner extends EventEmitter

  ###
  Set the initial values for the runner
  ###
  constructor: (config) ->
    @configure @defaults()
    @configure config if config
    @init() if @autoInit

  ###
  Default properties for benchmark runners
  ###
  defaults: ->
    index: -1
    suites: []
    initialized: false
    skip: []
    only: []
    autoInit: true
    tag: null
    reporter: new SpecReporter()
    historyFilename: "history.json"
    history: new History

  ###
  Configure the runner based on an object
  ###
  configure: (config) ->
    @[key] = value for key, value of config
    this

  ###
  Initialize the runner
  ###
  init: ->
    @restore =
      compare: global.compare
      suite: global.suite

    global.compare = @addComparison
    global.suite = @addSuite

    global.compare.only = (name, body) =>
      @only.push name
      global.compare name, body

    global.compare.skip = (name, body) =>
      @skip.push name
      global.compare name, body

    global.suite.only = (name, body) =>
      @only.push name
      global.suite name, body

    global.suite.skip = (name, body) =>
      @skip.push name
      global.suite name, body

    @initialized = true

  ###
  Destroy the runner
  ###
  destroy: ->
    global.compare = @restore.compare
    global.suite = @restore.suite
    @initialized = false

  ###
  Run the benchmarks
  ###
  run: =>

    completed = (suites) =>
      @removeListener "start-suite", @reporter.onStartSuite
      @removeListener "start-benchmark", @reporter.onStartBenchmark
      @removeListener "complete-benchmark", @reporter.onCompleteBenchmark
      @removeListener "complete-suite", @reporter.onCompleteSuite
      @reporter.onComplete suites

    run = =>
      @reporter.runner = this
      @reporter.onStart @suites
      @on "start-suite", @reporter.onStartSuite
      @on "start-benchmark", @reporter.onStartBenchmark
      @on "complete-benchmark", @reporter.onCompleteBenchmark
      @on "complete-suite", @reporter.onCompleteSuite
      @on "complete", (suites) =>
        if @history?
          @history.addRun @tag, new Date, suites
          @history.save @historyFilename, (err) ->
            throw err if err
            completed suites
        else
          completed suites

      @index = -1
      @runNext()



    if @history
      @history.load @historyFilename, run
    else
      run()

  ###
  Run the next benchmark, or complete if finished
  ###
  runNext: =>
    @index += 1
    suite = @suites[@index]
    return @complete() unless suite?
    if ~@skip.indexOf suite.name
      @emit "skip-suite"
      return @runNext()
    return @runNext() if @only.length and not ~@only.indexOf suite.name
    suite.run
      async: true

  ###
  Invoked when the tests complete
  ###
  complete: =>
    @emit "complete", @suites



  ###
  Add a named benchmark suite
  ###
  addSuite: (name, fn) =>
    suite = new Benchmark.Suite name
    @runWithGlobals suite, fn
    @bindToSuite suite
    @suites.push suite
    this

  ###
  Add a named comparison suite
  ###
  addComparison: (name, fn) =>
    suite = new Benchmark.Suite name
    suite.isComparison = true
    @runWithGlobals suite, fn
    @bindToSuite suite
    @suites.push suite
    this

  ###
  Bind to suite events
  ###
  bindToSuite: (suite) =>
    suite.on 'start', =>
      @emit 'start-suite', suite
    suite.on 'complete', =>
      @emit 'complete-suite', suite
      @runNext()
    suite

  ###
  Run the given function with the global helper methods available
  ###
  runWithGlobals: (suite, fn) =>
    restore =
      before: global.before
      after: global.after
      benchmark: global.benchmark

    global.before = (callback) ->
      suite.on 'start', callback
    global.after = (callback) ->
      suite.on 'complete', callback
    global.benchmark = (name, bench) =>
      opts =
        onStart: (event) =>
          @emit 'start-benchmark', suite, event.target
        onComplete: (event) =>
          @emit 'complete-benchmark', suite, event.target
      if bench.length
        opts.defer = true
        wrapped = (deferred) ->
          bench -> deferred.resolve()
      else
        wrapped = bench
      suite.add name, wrapped, opts


    result = fn()

    global.before = restore.before
    global.after = restore.after
    global.benchmark = restore.benchmark

    result



