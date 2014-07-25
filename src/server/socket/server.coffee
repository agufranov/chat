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
      res.write "\nRooms:\n"
      (
        res.write "#{room}: "
        res.write members.join(", ")
        res.write "\n"
      ) for room, members of io.sockets.adapter.rooms
      res.write JSON.stringify io.sockets.adapter.rooms
      res.end()
    http = http.createServer httpHandler
    .listen port

    # Сервер Socket.IO
    io = socketio http

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
      io.to("t").emit "debug", "RRRRR"
      socket.broadcast.to("t").emit "debug", "EEEEEEE"
      sessionStore.add socket

      # Отключение сокета
      socket.on "disconnect", ->
        delete io.sockets.adapter.rooms[socket.id]
        sessionStore.delete socket

      messenger.addHandlers(socket)

module.exports = Server
