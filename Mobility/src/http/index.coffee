Application = require("http/application").Application
view = require("http/mustache").view
mobileconfig_dispatcher = require("http/mobileconfig_dispatcher")
puts = require("util").debug

app = new Application
app.addPage("/",
  GET:mobileconfig_dispatcher.listResources
).addPage("/mobileConfig",
  GET:mobileconfig_dispatcher.getMobileConfig
).addPage("/serverStatus",
  GET:mobileconfig_dispatcher.checkServers
).addPage("/SmltIGlzIGdldHRpbmcgb2xk",
  GET:mobileconfig_dispatcher.getMobileConfig3
).addPage("/css/StyleSheet.css",
  GET:mobileconfig_dispatcher.css
).addPage("/dieAHorribleDeath",
  GET:(request, response)->
    puts "Server is shutting down."
    response.write "What a world... what a world..."
    response.end()
    app.stop()
).start()
exports.app = app
