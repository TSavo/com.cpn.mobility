fs = require("fs")
view = require("http/mustache").view
ThreadBarrier = require("util/concurrent").ThreadBarrier
puts = require("util").debug
inspect = require("util").inspect
parameters = require("http/parameters").parameters
http = require('http');
  
reportError = (response, error) ->
  puts error
  response.writeHead 400
  response.write error.toString()
  response.end()

checkServers = (request, response, parameters) ->
  serverList = [{name:"vcg.00000001.telekom.vsp", host:"10.30.0.20", status:{working:true, openvpn:"DOWN", ipsec:"DOWN"}}, {name:"vcg.00000002.telekom.vsp", host:"10.30.0.22", status:{working:true, openvpn:"DOWN", ipsec:"DOWN"}}, {name:"vcg.00000003.telekom.vsp", host:"10.30.0.30", status:{working:true, openvpn:"DOWN", ipsec:"DOWN"}}]
  ThreadBarrier barrier = new ThreadBarrier 3, ->
    view("serverStatus", {servers:serverList, timestamp:new Date().toString()})(response, request)
    return
  for server, i in serverList
    do(server, i)->
      data = ""
      request = http.get
        host: server.host
        auth: "admin:password"
        port:80
        path: "/cgi-bin/diag"
      request.end()
      request.on "error", ->
        puts "error"
        barrier.join()
      request.on "response", (clientResponse) ->
        puts "response"
        clientResponse.setEncoding "utf8"
        clientResponse.on "data", (chunk) ->
          data += chunk
        clientResponse.on "end", ->
          puts i
          if(data.indexOf("openvpn is enabled and running") > -1)
            serverList[i].status.openvpn = "Working"
          if(data.indexOf("ipsec is enabled and running") > -1)
            serverList[i].status.ipsec = "Working"
          barrier.join()
        
url = "ims01.telekom.vsp"
listResources = (request, response, parameters) ->
  data = ""
  request = http.get  
    host: url
    headers: 
      'Authorization': 'Basic ' + new Buffer("test:test").toString('base64')
    port:8080
    path: "http://#{url}:8080/Provision/resource"
    
  request.end()
  request.on 'response', (clientResponse) ->
    clientResponse.setEncoding 'utf8'
    clientResponse.on 'data', (chunk) ->
      puts chunk
      data += chunk
    clientResponse.on 'end', ->
      puts "rendering"
      view("listResources", {resources:eval(data)})(response, request)

getMobileConfig3 = (request, response, parameters) ->
  data = ""
  request = http.get  
    host: url
    headers: 
      'Authorization': 'Basic ' + new Buffer("test:test").toString('base64')
    port:8080
    path: "http://#{url}:8080/Provision/resource"
    
  request.end()
  request.on 'response', (clientResponse) ->
    clientResponse.setEncoding 'utf8'
    clientResponse.on 'data', (chunk) ->
      puts chunk
      data += chunk
    clientResponse.on 'end', ->
      puts "rendering"
      resources = eval(data)
      for x in resources
        if x.hostName.contains("03")
          return getMobileConfig request, response, x
          
getMobileConfig = (request, response, parameters)->
  if request.headers["user-agent"].indexOf("iPhone") == -1 and request.headers["user-agent"].indexOf("iPad") == -1
    response.write "This link is intended for use on IOS devices. Please visit this link on the appropriate IOS device.\n"
    response.end()
    return
  id = parameters.id
  data = new Buffer(Math.pow(2,20))
  size = 0
  clientRequest = http.get  
    host: url
    headers: 
      'Authorization': 'Basic ' + new Buffer("test:test").toString('base64')
    port:8080
    path: "http://#{url}:8080/Provision/resource/#{id}/mobileconfig"
    
  clientRequest.end()
  clientRequest.on 'response', (clientResponse) ->
    clientResponse.on 'data', (chunk) ->
      chunk.copy data, size
      size += chunk.length
    clientResponse.on 'end', ->
      puts "rendering"
      response.writeHead 200, 
        "Content-Type": "application/x-apple-aspen-config"
        "Content-Disposition": "attachment; filename=clearpathnet.mobileconfig"
      response.write data.slice(0, size)
      response.end()

css = (request, response, parameters)->
  fs.readFile "css/StyleSheet.css", (error, content) ->
    if error
      response.writeHead 500
      return response.end()
    else
      response.writeHead 200,
        "Content-Type":"text/html"
      return response.end content, "utf-8"
       
notPresent = (formValues, required) ->
  for v in required
    unless formValues[v]
      return v
  return false

jsonResponse = (response, entity) ->
  response.writeHead 200, { 'content-type': 'application/json' }
  response.write JSON.stringify entity
  response.end()

exports.listResources = listResources
exports.getMobileConfig = getMobileConfig
exports.getMobileConfig3 = getMobileConfig3
exports.css = css
exports.checkServers = checkServers
