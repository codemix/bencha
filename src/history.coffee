fs = require "fs"

module.exports = class History

  ###
  Whether or not to only store uniquely tagged runs
  ###
  uniquesOnly: true

  ###
  Holds the loaded runs
  ###
  runs: []

  ###
  Add the results of a set of suites
  ###
  addRun: (tag, timestamp, suites) ->
    obj =
      tag: tag
      timestamp: timestamp
      suites: {}

    for suite in suites
      obj.suites[suite.name] = {}
      for benchmark in suite
        continue unless benchmark.times.cycle
        obj.suites[suite.name][benchmark.name] =
          hz: benchmark.hz
          cycles: benchmark.cycles
          count: benchmark.count
          times: benchmark.times

    @runs.unshift obj
    obj


  load: (filename, callback) =>
    fs.readFile filename, "utf8", (err, contents) =>
      return callback err if err
      try
        @runs = JSON.parse contents
      catch e
        @runs = []
      @runs = [] unless Array.isArray @runs
      callback null, this

  save: (filename, callback) =>
    runs = @runs
    if @uniquesOnly
      seen = []
      runs = runs.filter (run) ->
        return true unless run.tag?
        return false if ~seen.indexOf run.tag
        seen.push run.tag
        true
    fs.writeFile filename, JSON.stringify(runs, null, 2), (err) =>
      return callback err if err
      callback null, this

  ###
  Find the previous runs for the given benchmark
  ###
  findPreviousRuns: (suite, benchmark, limit) ->
    results = []
    for run in @runs
      continue unless run.suites[suite.name]?[benchmark.name]?
      results.push run.suites[suite.name][benchmark.name]
      break if limit and results.length >= limit
    results

  ###
  Return true if the given benchmark is a performance regression, within
  the given error margin
  ###
  isRegression: (suite, benchmark, errorMarginInPercent = 0.00005) ->
    previous = @findPreviousRuns(suite, benchmark, 1).shift()
    return false unless previous?
    difference = benchmark.hz - previous.hz
    percentageDifference = ((difference / benchmark.hz) * 100).toFixed(3)
    percentageDifference <= (0 - errorMarginInPercent)

  ###
  Return true if the given benchmark is a performance improvement, within
  the given error margin
  ###
  isImprovement: (suite, benchmark, errorMarginInPercent = 0.000005) ->
    previous = @findPreviousRuns(suite, benchmark, 1).shift()
    return false unless previous?
    difference = benchmark.hz - previous.hz
    percentageDifference = ((difference / benchmark.hz) * 100).toFixed(3)
    percentageDifference >= errorMarginInPercent

