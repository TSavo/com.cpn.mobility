http = require("http")
puts = require("util").debug
inspect = require("util").inspect

extend = (a, b, context, newobjs, aparent, aname, haveaparent) ->
  return a  if a is b
  return a  unless b
  key = undefined
  clean_context = false
  return_sublevel = false
  b_pos = undefined
  unless haveaparent
    aparent = a: a
    aname = "a"
  unless context
    clean_context = true
    context = []
    newobjs = []
  b_pos = context.indexOf(b)
  if b_pos is -1
    context.push b
    newobjs.push [ aparent, aname ]
  else
    return newobjs[b_pos][0][newobjs[b_pos][1]]
  for key of b
    if b.hasOwnProperty(key)
      if typeof a[key] is "undefined"
        if typeof b[key] is "object"
          if b[key] instanceof Array
            a[key] = extend([], b[key], context, newobjs, a, key, true)
          else if b[key] is null
            a[key] = null
          else if b[key] instanceof Date
            a[key] = new b[key].constructor()
            a[key].setTime b[key].getTime()
          else
            a[key] = extend({}, b[key], context, newobjs, a, key, true)
        else
          a[key] = b[key]
      else if typeof a[key] is "object" and a[key] isnt null
        a[key] = extend(a[key], b[key], context, newobjs, a, key, true)
      else
        a[key] = b[key]
  if clean_context
    context = null
    newobjs = null
  unless haveaparent
    aparent = null
    return a
  a

proxy = (request, response) ->
  if request.url == "/dieAHorribleDeath"
    server.close()
    response.end()
    process.exit(0)
    return
  mappings=
    "nodejs\.dev\.cpncloud\.net":
      host:"ims.dev.cpn.vsp"
      port:8080
  headers = extend request.headers,
    'Authorization': 'Basic ' + new Buffer("test:test").toString('base64')
    'X-Forwarded-For': request.connection.remoteAddress
    'X-Forwarded-Host': request.headers["host"]
    'X-Forwarded-Server': request.connection.address().address
  host = null
  port = null
  for k, v of mappings
    if new RegExp(k, "g").test(request.headers["host"].replace(/:[0-9]+/g, ""))
      host=v.host
      port=v.port
      break
  if !host or !port
    response.writeHead 404
    response.write "No mapping found for hostname "
    response.close
  clientRequest = http.get  
    host: host
    headers: headers
    port:port
    path: request.url
  clientRequest.on "error", (e)->
    response.writeHead 404
    response.write e.message
    response.end()
  clientRequest.on 'response', (clientResponse) ->
    response.writeHead clientResponse.statusCode, clientResponse.headers
    clientResponse.on 'data', (chunk) ->
      response.write chunk
    clientResponse.on 'end', ->
      response.end()
  clientRequest.end()
      

onRequest = (request, response) ->
  proxy request, response
server = http.createServer(onRequest).listen 80
puts "Server has started."
