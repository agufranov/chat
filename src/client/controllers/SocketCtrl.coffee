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
    #if !$scope.$$phase
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
      $rootScope.$on "socket:chat message from user", ->
        console.log "Chat message from user:", arguments

  $scope.disconnect = ->
    socketSvc.disconnect()

  $scope.chats = []

  $scope.sendMessage = (to, text) ->
    $scope.socket.emit "chat message to user", to, text

  $scope.addChat = (name) ->
    uid = prompt "User ID to chat with:"
    if uid?
      $scope.chats.push
        uid: uid
