settings = require "./settings"
SocketServer = require "./socket/server"

socketServer = new SocketServer settings.port
