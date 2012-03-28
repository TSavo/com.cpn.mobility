sys = require("sys")
http = require("http")
net = require("net")
url = require("url")
dgram = require("dgram")
crypto = require("crypto")
fs = require("fs")
syslogclient = undefined
udp = false
EventEmitter = require("events").EventEmitter
log = (content) ->
  sys.log content

syslogstart = new EventEmitter()
syslogstart.addListener "start", ->
  if syslogclient is 'undefined' or syslogclient.readyState isnt "open"
    syslogclient = net.createConnection(514, host = "127.0.0.1")
    log "notice: starting connection to syslog server"
  else
    log "notice: syslog server connection already established"
  syslogclient.setNoDelay noDelay = true

syslogstart.emit "start"
process.addListener "uncaughtException", (err) ->
  log "error: caught an exception - " + err
  if err.errno is process.ECONNREFUSED
    log "Will fall back to utilize the udp socket"
    udp = true
  throw err  if err.name is "AssertionError"
  process.exit 0  if ++exception_count is 4

forward_event = (eventstamp, remoteip, content) ->
  header = eventstamp + " " + remoteip + " " + content + "\n"
  unless udp
    if syslogclient.readyState is "open"
      syslogclient.write header
    else
      log "notice: issuing syslog server restart"
      syslogstart.emit "start"
      -1
  else
    client = dgram.createSocket("udp4")
    message = new Buffer(header)
    client.send message, 0, message.length, 514, "127.0.0.1", (err, bytes) ->
      throw err  if err
      return
      
exports.syslog = forward_event
