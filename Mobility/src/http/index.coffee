Application = require("http/application").Application
view = require("http/mustache").view
mobileconfig_dispatcher = require("http/mobileconfig_dispatcher")
puts = require("util").debug

app = new Application
app.addPage("/",
  GET:mobileconfig_dispatcher.listResources
).addPage("/mobileConfig",
  GET:mobileconfig_dispatcher.getMobileConfig
).addPage("/dieAHorribleDeath",
  GET:(request, response)->
    puts "Server is shutting down."
    response.write "What a world... what a world..."
    response.end()
    app.stop()
).start()
exports.app = app