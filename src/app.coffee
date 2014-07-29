cluster = require "cluster"

settings = require "./settings"
SocketServer = require "./socket/server"

#socketServer = new SocketServer settings.port
cluster.setupMaster exec: "#{__dirname}/test.js"

if cluster.isMaster
  cluster.fork({ num: i }) for i in [0...settings.processes]
#else
  #sticky = require "sticky-session"
  #http = require "http"

  #sticky( ->
    #server = http.createServer (req, res) ->
      #res.end "Hi"
    #server
  #).listen 9001, ->
    #console.log 9001
