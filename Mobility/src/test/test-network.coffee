TestSuite = require("util/test").TestSuite
puts = require("util").debug
ping = require("http/network").ping
isOpen = require("http/network").isOpen

suite = new TestSuite 

suite.newAsyncTest "We can ping a hostname", (assert, test) ->
  ping "yahoo.com", (error, stdout, stderr) ->
    assert.isNotError error
    test.done()

suite.newAsyncTest "We can ping a bad host name and we get back a error", (assert, test) ->
  ping "max-web.com", (error, stdout, stderr) ->
    assert.isError error
    test.done()

suite.newAsyncTest "Port 80 on yahoo.com is open", (assert, test) ->
  isOpen 80, "yahoo.com", (result)->
    assert.isTrue result
    test.done()
    
suite.newAsyncTest "Port 81 on yahoo.com is closed", (assert, test) ->
  isOpen 81, "yahoo.com", (result)->
    assert.isFalse result
    test.done()
    
suite.run()
