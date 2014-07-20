#userId = document.location.hash[1..]

#window.socket = io.connect "http://127.0.0.1:8001",
  #query: { userId: userId }

#log = (msg) ->
  #->
    #console.log msg, arguments

#[socket.on(name, log(name)) for name in [
  #"message"
  #"connected"
  #"connect"
  #"disconnect"
  #"disconnected"
  #"error"
#]]

#socket.on "message from user", (from, text) ->
  #console.log "Message from #{from}: #{text}"

#socket.on "messaging error", (error) ->
  #console.log error

#$(document).ready ->
  #$("#messaging").on "submit", (event) ->
    #socket.emit "message to user", $("[name=to]", this).val(), $("[name=text]", this).val()
    #event.preventDefault()
