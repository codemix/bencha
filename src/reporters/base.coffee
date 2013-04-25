{EventEmitter} = require "events"
Runner = require "../runner"

###
Base class for reporters
###
module.exports = class BaseReporter extends EventEmitter
  ###
  Create and optionally initialize the reporter
  ###
  constructor: ->
    @startTime = null
    @endTime = null
    @useColors = true


  ###
  Default color map
  ###
  colors:
    'pass': 90
    'fail': 31
    'bright pass': 92
    'bright fail': 91
    'bright yellow': 93
    'pending': 36
    'suite': 0
    'error title': 0
    'error message': 31
    'error stack': 90
    'checkmark': 32
    'fast': 90
    'medium': 33
    'slow': 31
    'green': 32
    'light': 90
    'diff gutter': 90
    'diff added': 42
    'diff removed': 41

  symbols: do ->
    if process.platform is 'win32'
      ok: '\u221A'

      err: '\u00D7'
      dot: '.'
    else
      ok: '✓'
      err: '✖'
      dot: '․'

  ###
  Colorize a string using a given colour name
  ###
  color: (name, str) ->
    return str unless @useColors
    "\u001b[#{@colors[name]}m#{str}\u001b[0m"


  ###
  The total time (in ms) for all benchmarks
  ###
  totalTime: ->
    @endTime - @startTime

  ###
  Invoked when the runner stars
  ###
  onStart: (runner) ->
    @startTime = Date.now()

  ###
  Invoked when a suite is started
  ###
  onStartSuite: (suite) ->

  ###
  Invoked when a suite ends
  ###
  onCompleteSuite: (suite) ->

  ###
  Invoked when a benchmark starts
  ###
  onStartBenchmark: (suite, benchmark) ->

  ###
  Invoked when a benchmark completes
  ###
  onCompleteBenchmark: (suite, benchmark) ->


  ###
  Invoked when all the suites have finished
  ###
  onComplete: (suites) ->
    @endTime = Date.now()
