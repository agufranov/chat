socketio = require "socket.io"

class Server
  constructor: (port) ->
    @io = socketio port
    @io.on "connection", (socket) =>
      id = socket.id
      console.log "#{id} connected"
      socket.send "Welcome, #{id}"
      socket.broadcast.send "#{id} connected"
      socket.on "disconnect", (socket) =>
        console.log "#{id} disconnected"
        @io.sockets.send "#{id} disconnected"

module.exports.Server = Server
