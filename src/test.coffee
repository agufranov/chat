SocketServer = require "./socket/server"
HttpServer = require "./http/server"

num = process.env["num"]
port = 20100 + parseInt num
console.log port
#httpServer = new HttpServer port, num
socketServer = new SocketServer port#httpServer

#sticky = require "sticky-session"
#http = require "http"

#sticky( ->
  #server = http.createServer (req, res) ->
    #res.end "Hi"
  #server
#).listen 9001, ->
  #console.log arguments
