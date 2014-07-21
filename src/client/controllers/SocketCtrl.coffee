App.controller "socketCtrl", ($rootScope, $scope, socketSvc) ->
  $scope.status = "Disconnected"
  $scope.isConnected = false

  $rootScope._socketHandled = false # Флаг, чтобы не повесить обработчики событий socket.io несколько раз

  urlUid = location.search[1..]
  $scope.uid = if urlUid != "" then urlUid else "user_xxx"

  $scope.socket = undefined

  $scope._setConnected = (isConnected, apply) ->
    $scope.status = if isConnected then "Connected" else "Disconnected"
    $scope.isConnected = isConnected

    if !isConnected
      $scope.recentUsers = {}

    if apply
      $scope.$apply()

  $scope.connect = ->
    $scope.socket = socketSvc.connect($scope.uid)
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
      $rootScope.$on "socket:users online", (event, users) ->
        $scope.recentUsers[uid] = true for uid in users when uid isnt $scope.uid
      $rootScope.$on "socket:users offline", (event, users) ->
        $scope.recentUsers[uid] = false for uid in users when uid isnt $scope.uid

  $scope.disconnect = ->
    socketSvc.disconnect()

  $scope.chats = []

  $scope.recentUsers = {}

  $scope.sendMessage = (to, text) ->
    $scope.socket.emit "chat message to user", to, text

  $scope.addChat = (uid) ->
    uid ?= prompt "User ID to chat with:"
    if uid?
      $scope.chats.push
        uid: uid
