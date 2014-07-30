redis = require "redis"
async = require "async"

settings = require "../settings"

class RedisStore
  constructor: (io, name) ->
    client = redis.createClient(settings.redis.port, settings.redis.host)

    getUid = (socket) ->
      socket.handshake.query.uid

    userConnectionsKey = (uid) ->
      "#{name}:user:#{uid}:connections"

    addUserConnection = (uid, sid, cb) ->
      client.sadd userConnectionsKey(uid), sid, cb

    removeUserConnection = (uid, sid, cb) ->
      client.srem userConnectionsKey(uid), sid, cb

    getUserConnectionsCount = (uid, cb) ->
      client.scard userConnectionsKey(uid), cb

    # Добавить подключение
    @add = (socket) ->
      sid = socket.id
      uid = getUid(socket)
      
      addUserConnection uid, sid, (err, reply) ->
        console.log err if err?
        getUserConnectionsCount uid, (err, reply) ->
          console.log "Connect. #{uid} connections: #{reply}"
          console.log err if err?
          if reply == 1
            console.log "#{uid} first login"
            io.emit "users online", [ uid ]

      @getOnlineUsers (err, reply) ->
        console.log "Online users:", reply
        socket.emit "users online", reply

    # Удалить подключение
    @remove = (socket) ->
      sid = socket.id
      uid = getUid(socket)
      removeUserConnection uid, sid, (err, reply) ->
        console.log err if err?
        getUserConnectionsCount uid, (err, reply) ->
          console.log "#Disconnect. #{uid} connections: #{reply}"
          console.log err if err?
          if reply == 0
            console.log "#{uid} last logout"
            io.emit "users offline", [ uid ]

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

    @getOnlineUsers = (cb) ->
      client.keys "*:user:*:connections", (err, reply) ->
        cb(err, (key.split(":")[2] for key in reply))

module.exports = RedisStore
