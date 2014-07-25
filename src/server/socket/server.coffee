socketio = require "socket.io"
http = require "http"

AuthProvider = require "../auth/authProvider"
MemoryStore = require "../session/memoryStore"
Perfmeter = require "../util/perfmeter"
Messenger = require "../messaging/messenger"

class Server
  constructor: (port) ->

    # HTTP-сервер для отладки
    httpHandler = (req, res) ->
      res.writeHead 200
      uids = sessionStore.getUids()
      (
        res.write "#{uid}: "
        res.write "#{Object.keys(sids).join(", ")}"
        res.write "\n"
      ) for uid, sids of uids
      res.end()
    http = http.createServer httpHandler
    .listen port

    # Сервер Socket.IO
    io = socketio http

    # Хранилище сессий
    sessionStore = new MemoryStore(io)

    # Обработчик сообщений
    messenger = new Messenger(sessionStore)

    # Авторизация
    io.set "authorization", AuthProvider.authorize

    getUid = (socket) ->
      socket.handshake.query.uid

    # Обработка событий
    # Подключение сокета
    io.on "connection", (socket) ->
      sessionStore.add socket

      # Отключение сокета
      socket.on "disconnect", ->
        sessionStore.delete socket

      messenger.addHandlers(socket)
        #pm = new Perfmeter()

        #missingAttrs = ( attrName for attrName in [ "to", "text", "id" ] when !msg[attrName]? )

        #if missingAttrs.length > 0
          #console.log "Missing attributes for message: #{missingAttrs.join ", "}"
          #return

        #if !(toSocket = @findSocket msg.to)?
          #socket.emit "messaging error", "ERROR" # details
        #else
          #t2 = new Date().getTime()
          #pm.stop()
          #toSocket.emit "chat message from user", { from: uid, text: msg.text, id: msg.id }

      ## Sending message receipt confirmation to user
      #socket.on "chat message receipt to user", (msg) =>
        #if !(toSocket = @findSocket msg.to)?
          #socket.emit "messaging error", "ERROR" # details
        #toSocket.emit "chat message receipt to user", { from: uid, id: msg.id }

      ## Sending "start typing" notification to user
      #socket.on "chat user start typing", (uid) =>
        #return if !(toSocket = @findSocket uid)?
        #toSocket.emit "chat user start typing", socket.handshake.query.uid

      ## Sending "stop typing" notification to user
      #socket.on "chat user stop typing", (uid) =>
        #return if !(toSocket = @findSocket uid)?
        #toSocket.emit "chat user stop typing", socket.handshake.query.uid

      #socket.on "disconnect", (socket) =>
        #@store.removeUser uid
        #console.log "#{uid} disconnected"
        #@io.emit "users offline", [ uid ]

module.exports = Server
