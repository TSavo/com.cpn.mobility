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
  id = parameters.id
  data = new Buffer(Math.pow(2,20))
  size = 0
  request = http.get  
    host: url
    headers: 
      'Authorization': 'Basic ' + new Buffer("test:test").toString('base64')
    port:8080
    path: "http://#{url}:8080/Provision/resource/#{id}/mobileconfig"
    
  request.end()
  request.on 'response', (clientResponse) ->
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
