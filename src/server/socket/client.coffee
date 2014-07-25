console.log process.argv

io = require "socket.io-client"

settings = require "../settings"

socket = io.connect "http://127.0.0.1:#{settings.port}",
  query:
    uid: "test_#{process.argv[2]}"
socket.on "connect", ->
  console.log arguments
