App.controller "socketCtrl", ($rootScope, $scope, socketSvc) ->
  $scope.status = "Disconnected"
  $scope.isConnected = false

  $rootScope._socketHandled = false # Флаг, чтобы не повесить обработчики событий socket.io несколько раз

  urlUid = location.search[1..]
  $rootScope.uid = if urlUid != "" then urlUid else "user_xxx"

  $scope.socket = undefined

  $scope._setConnected = (isConnected, apply) ->
    $scope.status = if isConnected then "Connected" else "Disconnected"
    $scope.isConnected = isConnected

    if !isConnected
      $scope.recentUsers = {}

    if apply
      $scope.$apply()

  $scope.pendingMessages = {}

  $scope.connect = ->
    $scope.socket = socketSvc.connect($rootScope.uid)
    if !$rootScope._socketHandled # Если обработчики еще не повешены
      $rootScope._socketHandled = true

      $rootScope.$on "socket:connect", (event) ->
        console.log "connected"
        $scope._setConnected true, true

      $rootScope.$on "socket:disconnect", (event) ->
        console.log "disconnected"
        $scope._setConnected false, false

      $rootScope.$on "socket:error", (event, error) ->
        console.log "[error] #{error}"

      $rootScope.$on "socket:message", (event, message) ->
        console.log "[message] #{message}"

      $rootScope.$on "socket:messaging error", (event, error) ->
        console.log "[messaging error] #{error}"

      $rootScope.$on "socket:chat", (event, message) ->
        console.log "Chat message from user:", message
        chat = $scope.chats[message.from]
        msg =
          direction: "in"
          body: message.body
          from: message.from
          to: $rootScope.uid
          id: message.id
          read: false
          timestamp: message.timestamp
        if !chat?
          messages = {}
          messages[msg.id] = msg
          $scope.addChat message.from, messages
        else
          chat.messages[msg.id] = msg

      $rootScope.$on "socket:room chat", (event, message) ->
        msg =
          direction: "in"
          body: message.body
          from: message.from
          to: message.to
          id: message.id
          read: false
          timestamp: message.timestamp
        if (roomChat = $scope.roomChats[message.to])?
          roomChat.messages[msg.id] = msg
          console.log "room chat: #{msg.body}", roomChat

      $rootScope.$on "socket:my chat", (event, message) ->
        console.log "My chat", message
        chat = $scope.chats[message.to]
        msg =
          direction: "out"
          body: message.body
          from: $rootScope.uid
          to: message.to
          id: message.id
          read: false
          timestamp: message.timestamp
        if !chat?
          messages = {}
          messages[msg.id] = msg
          $scope.addChat message.to, messages
        else
          chat.messages[msg.id] = msg

      $rootScope.$on "socket:chat timestamp", (event, message) ->
        chat = $scope.chats[message.to]
        chat.messages[message.id].timestamp = message.timestamp

      $rootScope.$on "socket:chat receipt", (event, msg) ->
        if(chat = $scope.chats[msg.from])
          if(message = chat.messages[msg.id])
            message.read = true
        delete $scope.pendingMessages[msg.id]

      $rootScope.$on "socket:chat typing", (event, chat) ->
        chatWith = $scope.chats[chat.uid]
        chatWith.typing = chat.typing if chatWith

      $rootScope.$on "socket:join room", (event, data) ->
        console.log "#{data.uid} joined room #{data.room}"

      $rootScope.$on "socket:room joined", (event, options) ->
        $scope.roomChats[options.name] =
          name: options.name
          messages: {}
        console.log "You have successfully joined the room #{options.name}"

      # room chat

      $rootScope.$on "socket:users online", (event, users) ->
        $scope.recentUsers[uid] = true for uid in users when uid isnt $rootScope.uid

      $rootScope.$on "socket:users offline", (event, users) ->
        $scope.recentUsers[uid] = false for uid in users when uid isnt $rootScope.uid

      $rootScope.$on "socket:debug", (event, t) ->
        console.log "DEBUG:", t

      $rootScope.$on "socket:hello", (event, msg) ->
        console.log "HELLO: #{msg}"

      $rootScope.$on "socket:debug server name", (event, name) ->
        console.log name
        $scope.serverName = name

  $scope.disconnect = ->
    socketSvc.disconnect()

  $scope.chats = {}
  $scope.roomChats = {}

  $scope.recentUsers = {}

  $scope.sendMessage = (msg) ->
    $scope.socket.emit "chat", msg
    $scope.pendingMessages[msg.id] =
      id: msg.id

  $scope.sendMessageReceipt = (msg) ->
    $scope.socket.emit "chat receipt",
      id: msg.id
      to: msg.from

  $scope.sendTyping = (uid, typing) ->
    $scope.socket.emit "chat typing",
      uid: uid
      typing: typing

  $scope.addChat = (uid, messages = {}) ->
    uid ?= prompt "User ID to chat with:"
    if uid?
      $scope.chats[uid] =
        uid: uid
        messages: messages
        typing: false

  $scope.getHistory = (uid, limit, offset) ->
    rid = btoa(Math.random())
    removeHandler = $rootScope.$on "socket:get history", (event, history) ->
      if history.rid == rid
        removeHandler()
        if (chat = $scope.chats[uid])
          (
            chat.messages[msg.local_id] =
              body: msg.body
              from: msg.from
              to: msg.to
              read: msg.read
              timestamp: msg.timestamp
              id: msg.local_id
              direction: msg.direction
          ) for msg in history.messages

    $scope.socket.emit "get history",
      rid: rid
      with: uid
      offset: offset
      limit: limit

  $scope.joinRoom = ->
    if (name = prompt "Room name:")
      $scope.socket.emit "join room",
        name: name

  $scope.sendRoomMessage = (msg) ->
    $scope.socket.emit "room chat", msg

  $scope.connect()
