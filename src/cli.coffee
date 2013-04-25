optimist = require "optimist"
require "coffee-script"
path = require "path"
Runner = require "./runner"
reporters = require "./reporters"
{exec} = require "child_process"

run = (argv = process.argv) ->
  argv = optimist(argv).argv
  fn = (tag) ->
    dir = argv.dir or path.join process.cwd(), "bench"
    historyFilename = argv.history or path.join process.cwd(), "bench", "history.json"
    reporterName = argv.reporter or "spec"
    runner = new Runner
      historyFilename: historyFilename
      reporter: new reporters[reporterName]
      tag: tag
    require dir
    runner.run()
  if argv.tag
    fn tag
  else if argv.vcs
    loadTag argv.vcs, (err, tag) ->
      throw err if err
      fn tag
  else
    loadTag "git", (err, tag) ->
      tag = String new Date if err
      fn tag

loadTag = (type = "git", callback) ->
  switch type
    when "git"
      return exec "git rev-parse HEAD", (err, tag) ->
        callback err, String(tag).trim()



###
Bencha command line interface
###
module.exports =
  run: run
