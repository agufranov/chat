express = require "express"
livereload = require "express-livereload"

class Server
  constructor: (port, name) ->
    app = express()
    #livereload(app, config={ port: port + 100 })

    app.get "/", (req, res) ->
      res.send name

    app.use express.static "#{__dirname}/../public"

    @server = app.listen port

module.exports = Server
