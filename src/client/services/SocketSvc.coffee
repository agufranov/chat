App.factory "SocketSvc", ($rootScope, socketFactory) ->
  mySocket = null
  connect: (uid) ->
    mySocket = socketFactory
      ioSocket: io.connect "http://127.0.0.1:8001",
        "force new connection": true
        query:
          uid: "user1"
    mySocket.forward [
      "connect"
      "disconnect"
      "message"
      "error"
    ]
    mySocket
  disconnect: ->
    mySocket.disconnect()
