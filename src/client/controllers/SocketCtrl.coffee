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

  $scope.$watch "pendingMessages", ->
    console.log "pendingMessages changed", arguments

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

      $rootScope.$on "socket:chat message from user", (event, message) ->
        console.log "Chat message from user:", message
        chat = $scope.chats[message.from]
        msg =
          direction: "in"
          text: message.text
          from: message.from
          to: $rootScope.uid
          id: message.id
          received: false
        if !chat?
          messages = {}
          messages[msg.id] = msg
          $scope.addChat message.from, messages
        else
          chat.messages[msg.id] = msg

      $rootScope.$on "socket:chat message receipt to user", (event, msg) ->
        $scope.chats[msg.from].messages[msg.id].received = true
        delete $scope.pendingMessages[msg.id]

      $rootScope.$on "socket:chat user start typing", (event, uid) ->
        chat = $scope.chats[uid]
        chat.typing = true if chat

      $rootScope.$on "socket:chat user stop typing", (event, uid) ->
        chat = $scope.chats[uid]
        chat.typing = false if chat

      $rootScope.$on "socket:users online", (event, users) ->
        $scope.recentUsers[uid] = true for uid in users when uid isnt $rootScope.uid

      $rootScope.$on "socket:users offline", (event, users) ->
        $scope.recentUsers[uid] = false for uid in users when uid isnt $rootScope.uid

  $scope.disconnect = ->
    socketSvc.disconnect()

  $scope.chats = {}

  $scope.recentUsers = {}

  $scope.sendMessage = (msg) ->
    $scope.socket.emit "chat message to user", msg
    $scope.pendingMessages[msg.id] =
      id: msg.id

  $scope.sendMessageReceipt = (msg) ->
    $scope.socket.emit "chat message receipt to user",
      id: msg.id
      to: msg.from

  $scope.sendStartTyping = (uid) ->
    $scope.socket.emit "chat user start typing", uid

  $scope.sendStopTyping = (uid) ->
    $scope.socket.emit "chat user stop typing", uid

  $scope.addChat = (uid, messages = {}) ->
    uid ?= prompt "User ID to chat with:"
    if uid?
      $scope.chats[uid] =
        uid: uid
        messages: messages
        typing: false

  $scope.connect()
