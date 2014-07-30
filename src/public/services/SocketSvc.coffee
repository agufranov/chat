App.factory "socketSvc", ($rootScope, socketFactory) ->
  mySocket = null
  connect: (uid) ->
    console.log "Trying to connect..."
    mySocket = socketFactory
      ioSocket: io.connect "http://localhost:9000",
        #"force new connection": true
        query:
          uid: uid
    mySocket.forward [
      "connect"
      "disconnect"
      "message"
      "error"
      "messaging error"
      "chat"
      "my chat"
      "chat receipt"
      "chat timestamp"
      "chat typing"
      "get history"
      "join room"
      "room joined"
      "room chat"
      "users online"
      "users offline"
      "debug"
      "hello"
      "debug server name"
    ]
    mySocket
  disconnect: ->
    mySocket.disconnect()
