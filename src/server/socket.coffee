socketio = require "socket.io"
Store = require "./store"
Perfmeter = require "./util/perfmeter"


class Server
  constructor: (port) ->
    @io = socketio port
    @store = new Store()

    @io.set "authorization", (data, accept) ->
      uid = data._query.uid # uid (user ID) should come with connection
      if !uid?
        accept "uid is missing", false
      else
        accept null, true

    @findSocket = (uid) ->
      sid = @store.getSid uid
      return if !sid?
      @io.sockets.connected[sid]


    @io.on "connection", (socket) =>
      sid = socket.id
      uid = socket.handshake.query.uid

      @store.storeUser uid, sid

      console.log "#{uid} connected"

      # Send online users list to socket. Development purpose
      socket.emit "users online", @store.onlineUsers()

      socket.broadcast.emit "users online", [ uid ]

      socket.on "message", (msg) ->
        console.log "Message from #{uid}: #{msg}"

      # Sending message to user
      socket.on "chat message to user", (msg) =>
        pm = new Perfmeter()

        missingAttrs = ( attrName for attrName in [ "to", "text", "id" ] when !msg[attrName]? )

        if missingAttrs.length > 0
          console.log "Missing attributes for message: #{missingAttrs.join ", "}"
          return

        if !(toSocket = @findSocket msg.to)?
          socket.emit "messaging error", "ERROR" # details
        else
          t2 = new Date().getTime()
          pm.stop()
          toSocket.emit "chat message from user", { from: uid, text: msg.text, id: msg.id }

      # Sending message receipt confirmation to user
      socket.on "chat message receipt to user", (msg) =>
        if !(toSocket = @findSocket msg.to)?
          socket.emit "messaging error", "ERROR" # details
        toSocket.emit "chat message receipt to user", { from: uid, id: msg.id }

      # Sending "start typing" notification to user
      socket.on "chat user start typing", (uid) =>
        return if !(toSocket = @findSocket uid)?
        toSocket.emit "chat user start typing", socket.handshake.query.uid

      # Sending "stop typing" notification to user
      socket.on "chat user stop typing", (uid) =>
        return if !(toSocket = @findSocket uid)?
        toSocket.emit "chat user stop typing", socket.handshake.query.uid

      socket.on "disconnect", (socket) =>
        @store.removeUser uid
        console.log "#{uid} disconnected"
        @io.emit "users offline", [ uid ]

module.exports.Server = Server
