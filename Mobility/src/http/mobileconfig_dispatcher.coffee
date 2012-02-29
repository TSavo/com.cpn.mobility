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

listResources = (request, response, parameters) ->
  
  data = ""
  request = http.get  
    host: 'control.telekom.cpncloud.net'
    headers: 
      'Authorization': 'Basic ' + new Buffer("test:test").toString('base64')
    port:8080
    path: "http://control.telekom.cpncloud.net:8080/Provision/resource"
    
  request.end()
  request.on 'response', (clientResponse) ->
    clientResponse.setEncoding 'utf8'
    clientResponse.on 'data', (chunk) ->
      puts chunk
      data += chunk
    clientResponse.on 'end', ->
      puts "rendering"
      view("listResources", {resources:eval(data)})(response, request)


getMobileConfig = (request, response, parameters)->
  id = parameters.id
  data = ""
  request = http.get  
    host: 'control.telekom.cpncloud.net'
    headers: 
      'Authorization': 'Basic ' + new Buffer("test:test").toString('base64')
    port:8080
    path: "http://control.telekom.cpncloud.net:8080/Provision/resource/#{id}/mobileconfig"
    
  request.end()
  request.on 'response', (clientResponse) ->
    clientResponse.setEncoding 'utf8'
    clientResponse.on 'data', (chunk) ->
      puts chunk
      data += chunk
    clientResponse.on 'end', ->
      puts "rendering"
      response.writeHead 200, 
        "Content-Type": "application/x-apple-aspen-config"
        "Content-Disposition": "attachment; filename=clearpathnet.mobileconfig"
      response.write data
      response.end()


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
