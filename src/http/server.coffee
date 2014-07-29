express = require "express"

class Server
  constructor: (port, name) ->
    app = express()

    app.get "/", (req, res) ->
      res.send name

    console.log "#{__dirname}/public"
    app.use express.static "#{__dirname}/../public"

    app.listen port

module.exports = Server
