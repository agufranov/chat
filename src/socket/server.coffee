http = require "http"
socketio = require "socket.io"
socketioclient = require "socket.io-client"
socketioredis = require "socket.io-redis"

settings = require "../settings"
AuthProvider = require "../auth/authProvider"
RedisStore = require "../session/redisStore"
Perfmeter = require "../util/perfmeter"
Messenger = require "../messaging/messenger"

class Server
  # carrier - express сервер, http сервер или просто порт
  constructor: (carrier, name) ->
    # Сервер Socket.IO
    io = socketio.listen carrier

    # Соединение с монитором
    monitor = socketioclient.connect "http://localhost:9005",
      query:
        serverName: name

    # Адаптер Redis для коммуникации между экземплярами сервера
    io.adapter socketioredis host: settings.redis.host, port: settings.redis.port

    # Хранилище сессий
    sessionStore = new RedisStore(io, name)

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

      socket.emit "debug server name", name

      # Отключение сокета
      socket.on "disconnect", ->
        delete io.sockets.adapter.rooms[socket.id]
        sessionStore.remove socket

      messenger.addHandlers(socket)

module.exports = Server
