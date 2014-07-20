socketio = require "socket.io"
db = require "./db"

class Server
  constructor: (port) ->
    @io = socketio port
    @db = new db()

    @db.debug_flushall()

    @io.set "authorization", (data, accept) =>
      userId = data._query.userId #userId should come with connection
      if !userId?
        accept "userId is missing", false
      else
        accept null, true

    @io.on "connection", (socket) =>
      sid = socket.id
      uid = socket.handshake.query.userId

      @db.saveUserId sid, uid

      console.log "#{uid} connected"
      socket.send "Welcome, #{uid}"
      socket.broadcast.send "#{uid} connected"

      socket.on "message", (msg) =>
        console.log "Message from #{uid}: #{msg}"

      # Message to user
      socket.on "message to user", (to, text) =>
        console.log to, text
        @db.getSocketIdByUserId to, (sid) =>
          console.log sid
          toSocket = @io.sockets.connected[sid]
          if !toSocket?
            socket.emit "messaging error", "#{sid} is not connected"
          else
            toSocket.emit "message from user", uid, text

      socket.on "disconnect", (socket) =>
        @db.deleteUserId sid, uid
        console.log "#{uid} disconnected"
        @io.sockets.send "#{uid} disconnected"

module.exports.Server = Server
