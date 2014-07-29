cluster = require "cluster"

if cluster.isMaster
  (
    cluster.fork()
  ) for i in [1..500]
else
  socket = require("socket.io-client").connect "http://127.0.0.1:#{require("../settings").port}",
    query:
      uid: "test_#{Math.random()}"
