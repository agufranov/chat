cluster = require "cluster"

settings = require "./settings"
HttpServer = require "./http/server"
SocketServer = require "./socket/server"

#if cluster.isMaster
  #cluster.fork({ name: "Server ##{i}", port: settings.startPort + parseInt(i) }) for i in [0...settings.processes]
#else
httpServer = new HttpServer settings.startPort
socketServer = new SocketServer httpServer.server, "Single chat server"
