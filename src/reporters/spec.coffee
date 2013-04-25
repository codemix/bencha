BaseReporter = require "./base"
Benchmark = require "benchmark"

module.exports = class SpecReporter extends BaseReporter

  constructor: ->
    super
    @benchmarkCount = 0

  ###
  Invoked when the runner stars
  ###
  onStart: (runner) =>
    console.log @color 'light', "Benchmarking, please wait..."
    super

  ###
  Invoked when a suite is started
  ###
  onStartSuite: (suite) =>
    console.log " "
    if suite.isComparison
      console.log "    #{@color 'light', 'Compare:'} #{@color 'suite', suite.name}"
    else
      console.log "    #{@color 'light', 'Suite:'} #{@color 'suite', suite.name}"
    console.log " "
    super

  ###
  Invoked when a suite ends
  ###
  onCompleteSuite: (suite) =>
    console.log " "
    if suite.isComparison
      console.log "        #{@summarizeComparison suite}"
    else
      console.log "        #{@summarizeSuite suite}"
    console.log " "
    super

  ###
  Invoked when a benchmark starts
  ###
  onStartBenchmark: (suite, benchmark) =>
    console.log "        #{benchmark.name}"
    super

  ###
  Invoked when a benchmark completes
  ###
  onCompleteBenchmark: (suite, benchmark) =>
    @benchmarkCount += 1
    console.log "            #{@summarizeBenchmark suite, benchmark}"
    super


  ###
  Invoked when all the suites have finished
  ###
  onComplete: (suites) =>
    super
    console.log " "
    console.log "    #{@finalSummary suites}"
    console.log " "


  ###
  Nicely format a number
  ###
  formatNumber: (num) ->
    if num > 1000
      Benchmark.formatNumber Math.round num
    else
      Benchmark.formatNumber num
  ###
  Summarize the results of a benchmark
  ###
  summarizeBenchmark: (suite, benchmark) ->
    check = @color 'checkmark', @symbols.ok
    duration = "#{@color 'light', 'Completed in'} #{benchmark.times.elapsed}s"
    speed = "#{@color 'light', '('}#{@formatNumber benchmark.hz.toFixed 3} ops/sec#{@color 'light', ')'}"
    summary = "#{check} #{duration} #{speed}"
    if @runner.history.isRegression suite, benchmark
      "#{summary}\n            #{@summarizeRegression suite, benchmark}"
    else if @runner.history.isImprovement suite, benchmark
      "#{summary}\n            #{@summarizeImprovement suite, benchmark}"
    else
      summary

  summarizeRegression: (suite, benchmark) ->
    lastRun = @runner.history.findPreviousRuns(suite, benchmark, 1).shift()
    difference = lastRun.hz - benchmark.hz
    percentageDifference = ((difference / lastRun.hz) * 100).toFixed(3)
    cross = @color 'bright fail', @symbols.err
    diff = @color 'fail', "#{percentageDifference}%"

    regression = @color 'fail', "Regression,"
    slower = @color 'fail', "slower."
    "#{cross} #{regression} #{diff} #{slower}"



  summarizeImprovement: (suite, benchmark) ->
    lastRun = @runner.history.findPreviousRuns(suite, benchmark, 1).shift()
    difference = benchmark.hz - lastRun.hz
    percentageDifference = ((difference / benchmark.hz) * 100).toFixed(3)
    cross = @color 'bright pass', @symbols.ok
    diff = @color 'bright pass', "#{percentageDifference}%"
    improvement = @color 'green', "Improvement,"
    faster = @color 'green', 'faster.'
    "#{cross} #{improvement} #{diff} #{faster}"

  ###
  Return the total time in seconds for the suite
  ###
  suiteTotalTime: (suite) ->
    suite.reduce(
      (prev, benchmark) ->
        prev += benchmark.times.elapsed
      0
    ).toFixed 3

  ###
  Summarize the results of a suite
  ###
  summarizeSuite: (suite) ->
    "#{@color 'checkmark', @symbols.ok} Completed in #{@suiteTotalTime suite}s"

  ###
  Summarize the results of a comparison suite.
  ###
  summarizeComparison: (suite) ->
    return @summarizeSuite suite unless suite.length > 1
    fastestFirst = suite.sort (a, b) ->
      b.hz - a.hz
    fastest = fastestFirst[0]
    nextFastest = fastestFirst[1]
    difference = fastest.hz - nextFastest.hz
    percentageDifference = ((difference / fastest.hz) * 100).toFixed(3)

    check = @color 'checkmark', @symbols.ok
    duration = "#{@color 'light', 'Completed in'} #{@suiteTotalTime suite}s"
    speed = "#{@color 'bright pass', fastest.name} #{@color 'light', "was fastest by"} #{@color 'bright pass', "#{@formatNumber percentageDifference}%"}"
    "#{check} #{duration}, #{speed}"

  ###
  The final summary after all benchmarks have run
  ###
  finalSummary: (suites) ->
    seconds = (@totalTime() / 1000).toFixed(3)
    check = @color 'bright pass', "✔"
    total = @color 'green', "#{@benchmarkCount} benchmarks complete"
    time = @color 'light', "(#{seconds}s)"
    "#{check} #{total} #{time}"
