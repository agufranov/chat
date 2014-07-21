socketio = require "socket.io"
store = require "./store"

class Server
  constructor: (port) ->
    @io = socketio port
    @store = new store()

    @io.set "authorization", (data, accept) =>
      uid = data._query.uid # uid (user ID) should come with connection
      if !uid?
        accept "uid is missing", false
      else
        accept null, true

    @io.on "connection", (socket) =>
      sid = socket.id
      uid = socket.handshake.query.uid

      @store.storeUser uid, sid

      console.log "#{uid} connected"
      socket.send "Welcome, #{uid}"
      socket.broadcast.send "#{uid} connected"

      socket.on "message", (msg) =>
        console.log "Message from #{uid}: #{msg}"

      # Message to user
      socket.on "chat message to user", (to, text) =>
        console.log to, text
        sid = @store.getSid to
        if !sid?
          socket.emit "messaging error", "#{to} is not connected"
        else
          toSocket = @io.sockets.connected[sid]
          if !toSocket?
            socket.emit "messaging error", "#{to} is not connected"
          else
            toSocket.emit "chat message from user", uid, text

      socket.on "disconnect", (socket) =>
        @store.removeUser uid
        console.log "#{uid} disconnected"
        @io.sockets.send "#{uid} disconnected"

module.exports.Server = Server
