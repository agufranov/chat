class Store
  constructor: ->
    @uidToSid = {}

    @storeUser = (uid, sid) ->
      @uidToSid[uid] = sid

    @getSid = (uid) ->
      @uidToSid[uid]

    @removeUser = (uid) ->
      delete @uidToSid[uid]

    @onlineUsers = ->
      Object.keys @uidToSid

module.exports = Store
