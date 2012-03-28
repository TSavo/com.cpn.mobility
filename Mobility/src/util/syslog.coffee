dgram = require("dgram")
forward_event = (eventstamp, remoteip, content) ->
  header = eventstamp + " " + remoteip + " " + content + "\n"
  client = dgram.createSocket("udp4")
  message = new Buffer(header)
  client.send message, 0, message.length, 514, "127.0.0.1", (err, bytes) ->

syslog = (remoteip, content) ->
  dt = new Date()
  hours = dt.getHours()
  minutes = dt.getMinutes()
  seconds = dt.getSeconds()
  month = dt.getMonth()
  day = dt.getDate()
  months = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]
  eventstamp = months[month] + " " + day + " " + hours + ":" + minutes + ":" + seconds
  forward_event(eventstamp, remoteip, content)
      
exports.syslog = syslog