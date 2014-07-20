window.socket = io "http://127.0.0.1:8001"

socket.on "message", ->
  console.log arguments
