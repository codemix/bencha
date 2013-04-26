###
Bootstrap
###

redis = (require "redis").createClient()


###
Demo
###

compare "redis get vs set", ->
  after ->
    redis.quit()
  benchmark "set key", (done) ->
    redis.set "benchKeyTest", 100, (err, response) ->
      throw err if err
      done()
  benchmark "get key", (done) ->
    redis.get "benchKeyTest", (err, response) ->
      throw err if err
      done()

compare "regex vs string", ->
  benchmark "regex", ->
    /\./.test "foo.bar"
  benchmark "string", ->
    "foo.bar".indexOf(".") > -1


suite "string manipulation", ->
  benchmark "String::trim", ->
    "     foo     ".trim()

