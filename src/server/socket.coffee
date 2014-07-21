socketio = require "socket.io"
Store = require "./store"
Perfmeter = require "./util/perfmeter"


class Server
  constructor: (port) ->
    @io = socketio port
    @store = new Store()

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

      # Send online users list to socket. Development purpose
      socket.emit "users online", @store.onlineUsers()

      socket.broadcast.emit "users online", [ uid ]

      socket.on "message", (msg) =>
        console.log "Message from #{uid}: #{msg}"

      # Sending message to user
      socket.on "chat message to user", (to, text) =>
        pm = new Perfmeter()
        console.log to, text
        sid = @store.getSid to
        if !sid?
          socket.emit "messaging error", "#{to} is not connected"
        else
          toSocket = @io.sockets.connected[sid]
          if !toSocket?
            socket.emit "messaging error", "#{to} is not connected"
          else
            t2 = new Date().getTime()
            pm.stop()
            toSocket.emit "chat message from user", { from: uid, text: text }

      socket.on "disconnect", (socket) =>
        @store.removeUser uid
        console.log "#{uid} disconnected"
        @io.emit "users offline", [ uid ]

module.exports.Server = Server
