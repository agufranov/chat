PostgresProvider = require "./archive/postgresProvider"
Perfmeter = require "../util/perfmeter"

class Messenger
  constructor: (io, sessionStore) ->
    archiveProvider = new PostgresProvider
    getUid = (socket) ->
      socket.handshake.query.uid

    @addHandlers = (socket) ->
      thisUid = getUid(socket)

      # Отправка сообщения
      socket.on "chat", (msg) ->
        pm = new Perfmeter()
        msg.from = thisUid
        msg.timestamp = new Date().getTime()
        pm.restart "start:"
        archiveProvider.archiveMessage msg, (err, result) ->
          if err?
            console.log err
            socket.emit "messaging error", err
          else
          socket.emit "chat timestamp",
            to: msg.to
            id: msg.id
            timestamp: msg.timestamp
          socket.broadcast.to(thisUid).emit "my chat",
            to: msg.to
            body: msg.body
            id: msg.id
            timestamp: msg.timestamp
          io.to(msg.to).emit "chat",
            from: msg.from
            body: msg.body
            id: msg.id
            timestamp: msg.timestamp
          pm.restart "db"

      # Отправка подтверждения прочтения
      socket.on "chat receipt", (msg) ->
        msg.from = thisUid
        archiveProvider.markMessageAsRead msg.id, (err, result) ->
          if err?
            socket.emit "messaging error", err
          else
            socket.broadcast.to(thisUid).emit "chat receipt",
              from: msg.to
              id: msg.id
            io.to(msg.to).emit "chat receipt",
              from: msg.from
              id: msg.id

      # Отправка уведомления о наборе текста
      socket.on "chat typing", (chat) ->
        io.to(chat.uid).emit "chat typing",
          uid: thisUid
          typing: chat.typing

      # Получение истории
      socket.on "get history", (options) ->
        options.limit ||= 1000
        options.offset ||= 0
        archiveProvider.getHistory thisUid, options, (err, result) ->
          if err?
            socket.emit "messaging error", err
          else
            socket.emit "get history",
              rid: options.rid
              messages: result.rows

      # Присоединение к комнате
      socket.on "join room", (options) ->
        socket.join options.name, ->
          console.log "Join room:", arguments
          io.to(thisUid).emit "room joined",
            rid: options.rid
            name: options.name
          socket.broadcast.to(options.name).emit "join room",
            uid: thisUid
            room: options.name

      # Отправка сообщения в комнату
      socket.on "room chat", (msg) ->
        console.log "Room chat:", msg
        msg.from = thisUid
        socket.broadcast.to(msg.to).emit "room chat", msg

module.exports = Messenger
