PostgresProvider = require "./archive/postgresProvider"
Perfmeter = require "../util/perfmeter"

class Messenger
  constructor: (sessionStore) ->
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
        archiveProvider.archiveMessage msg, (err, result) ->
          if err?
            console.log err
            socket.emit "messaging error", err
          else
          socket.emit "chat timestamp",
            to: msg.to
            id: msg.id
            timestamp: msg.timestamp
          sessionStore.doExcept thisUid, socket.id, (socket) ->
            socket.emit "my chat",
              to: msg.to
              body: msg.body
              id: msg.id
              timestamp: msg.timestamp
          sessionStore.do msg.to, (socket) ->
            socket.emit "chat",
              from: msg.from
              body: msg.body
              id: msg.id
              timestamp: msg.timestamp
          pm.stop()

      # Отправка подтверждения прочтения
      socket.on "chat receipt", (msg) ->
        msg.from = thisUid
        archiveProvider.markMessageAsRead msg.id, (err, result) ->
          if err?
            socket.emit "messaging error", err
          else
            sessionStore.doExcept thisUid, socket.id, (socket) ->
              socket.emit "chat receipt",
                from: msg.to
                id: msg.id
            sessionStore.do msg.to, (socket) ->
              socket.emit "chat receipt",
                from: msg.from
                id: msg.id

      # Отправка уведомления о наборе текста
      socket.on "chat typing", (chat) ->
        sessionStore.do chat.uid, (socket) ->
          socket.emit "chat typing",
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

module.exports = Messenger
