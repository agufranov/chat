socketio = require "socket.io"
redis = require "redis"
async = require "async"

console.log 1

io = socketio.listen 9005

io.on "connection", (socket) ->
  client = redis.createClient()

  serverName = socket.handshake.query.serverName
  console.log "#{serverName} is up"

  socket.on "disconnect", ->
    console.log "#{serverName} is down"
    client.keys "#{serverName}:user:*:connections", (err, reply) ->
      console.log "Deleting keys:", reply
      async.map reply, (key) ->
        client.del key
      , ->
        console.log arguments
