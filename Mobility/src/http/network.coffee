exec = require("child_process").exec
puts = require("util").debug
inspect = require("util").inspect
net = require('net')
timeout = 400

pingCmd = "ping -c 1 "
if process.platform == "win32"
  pingCmd = "ping -n 1 "

ping = (hostname, callback) ->
  exec "#{pingCmd} #{hostname}", callback

exports.ping = ping

isOpen = (port, host, callback) ->
  isOpen = false
  conn=null
 
  onClose = ->
    delete conn
    callback isOpen, port, host

  onOpen = ->
    isOpen = true
    conn.end()
  conn = net.connect port, host, onOpen 

  conn.on "close", onClose
  conn.on "error", ->
    isOpen = false
    conn.end()
  conn.on "timeout", ->
    conn.end()
    onClose()


exports.setTimeout = (t) ->
  timeout = t
  
exports.isOpen = isOpen