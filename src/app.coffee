cluster = require "cluster"

settings = require "./settings"
HttpServer = require "./http/server"
SocketServer = require "./socket/server"

#if cluster.isMaster
  #cluster.fork({ name: "Server ##{i}", port: settings.startPort + parseInt(i) }) for i in [0...settings.processes]
#else
name = "Single chat server 1"
httpServer = new HttpServer settings.startPort, name
socketServer = new SocketServer httpServer.server, name
