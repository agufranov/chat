# Отвечает за хранение подключений. Хранит их в памяти.
# Каждый uid (user id) может иметь несколько подключений с разных sid (socket id).
class MemoryStore
  constructor: (io) ->
    uids = {}
    rooms = {}

    getUid = (socket) ->
      socket.handshake.query.uid

    # Добавить подключение
    @add = (socket) ->
      sid = socket.id
      uid = getUid(socket)
      if !(uid of uids)
        uids[uid] = {}
        firstConnect = true
      uids[uid][sid] = {}

      socket.emit "users online", @onlineUsers()
      if firstConnect
        io.emit "users online", [ uid ]
        console.log "User online: #{uid}"

    # Удалить подключение
    @delete = (socket) ->
      sid = socket.id
      uid = getUid(socket)
      delete uids[uid][sid]
      if Object.keys(uids[uid]).length == 0
        delete uids[uid]
        lastDisconnect = true

      if lastDisconnect
        io.emit "users offline", [ uid ]
        console.log "User offline: #{uid}"

    # Добавить пользователя в комнату
    #@addToRoom = (

    ## Выполнить действие для всех сокетов с таким-то uid
    #@do = (uid, fn) ->
      #sockets = (io.sockets.connected[sid] for sid of uids[uid])
      #fn(socket) for socket in sockets

    ## Выполнить действие для всех сокетов с таким-то uid, кроме одного
    #@doExcept = (uid, excludeSid, fn) ->
      #sockets = (io.sockets.connected[sid] for sid of uids[uid] when sid != excludeSid)
      #fn(socket) for socket in sockets

    @getUids = ->
      uids

    @onlineUsers = ->
      Object.keys uids

module.exports = MemoryStore
