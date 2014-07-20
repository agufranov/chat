redis = require "redis"

class Db
  constructor: ->
    @client = redis.createClient()

  debug_flushall: ->
    @client.flushall() # clean db for easier debugging

  saveUserId: (sid, uid) ->
    @client.set "socket_#{sid}", uid
    @client.set "user_#{uid}", sid

  deleteUserId: (sid, uid) ->
    @client.del "socket_#{sid}"
    @client.del "user_#{uid}"

  getSocketIdByUserId: (uid, cb) ->
    @client.get "user_#{uid}", (err, reply) ->
      cb reply

module.exports = Db
