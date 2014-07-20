window.MyCtrl = ($scope) ->
  $scope.status = "Disconnected"
  $scope.isConnected = false

  $scope.uid = "user_x"

  $scope.socket = undefined

  $scope._setConnected = (isConnected, apply) ->
    $scope.status = if isConnected then "Connected" else "Disconnected"
    $scope.isConnected = isConnected
    #if !$scope.$$phase
    if apply
      $scope.$apply()

  $scope.connect = ->
    $scope.socket = io.connect "http://127.0.0.1:8001", { "force new connection": true, query: { userId: $scope.uid } }
    $scope.socket.on "connect", ->
      console.log "connected"
      $scope._setConnected true, true
    $scope.socket.on "disconnect", ->
      console.log "disconnected"
      $scope._setConnected false, false

  $scope.disconnect = ->
    $scope.socket.disconnect()
