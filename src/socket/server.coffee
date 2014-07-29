http = require "http"
socketio = require "socket.io"
socketioredis = require "socket.io-redis"

AuthProvider = require "../auth/authProvider"
MemoryStore = require "../session/memoryStore"
Perfmeter = require "../util/perfmeter"
Messenger = require "../messaging/messenger"

class Server
  constructor: (port) ->
    # Сервер Socket.IO
    io = socketio port

    # Адаптер Redis для коммуникации между экземплярами сервера
    io.adapter socketioredis host: "localhost", port: 6379

    # Хранилище сессий
    sessionStore = new MemoryStore(io)

    # Обработчик сообщений
    messenger = new Messenger(io, sessionStore)

    # Авторизация
    io.set "authorization", AuthProvider.authorize

    getUid = (socket) ->
      socket.handshake.query.uid

    # Обработка событий
    # Подключение сокета
    io.on "connection", (socket) ->
      socket.join getUid socket
      sessionStore.add socket

      socket.emit "hello", "Server on port #{port}"
      io.emit "hello", "#{getUid socket} connected to port #{port}"
      socket.emit "debug port", port

      # Отключение сокета
      socket.on "disconnect", ->
        delete io.sockets.adapter.rooms[socket.id]
        sessionStore.delete socket

      messenger.addHandlers(socket)

module.exports = Server