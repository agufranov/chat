App.factory "socketSvc", ($rootScope, socketFactory) ->
  mySocket = null
  connect: (uid) ->
    mySocket = socketFactory
      ioSocket: io.connect "http://127.0.0.1:8001",
        "force new connection": true
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
      "users online"
      "users offline"
    ]
    mySocket
  disconnect: ->
    mySocket.disconnect()
