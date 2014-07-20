window.MyCtrl = ($scope) ->
  $scope.status = "Disconnected"
  $scope.isConnected = false

  $scope.uid = "user_x"

  $scope.socket = undefined

  $scope._setConnected = (isConnected) ->
    $scope.status = if isConnected then "Connected" else "Disconnected"
    console.log $scope.status
    $scope.isConnected = isConnected
    if !$scope.$$phase
      $scope.$apply()

  $scope.connect = ->
    console.log "connect click"
    $scope.socket = io.connect "http://127.0.0.1:8001", { "force new connection": true, query: { userId: $scope.uid } }
    $scope.socket.on "connect", ->
      console.log "connected"
      $scope._setConnected true
    $scope.socket.on "disconnect", ->
      console.log "disconnected"
      $scope._setConnected false
      console.log $scope.status
      console.log $scope.isConnected

  $scope.disconnect = ->
    $scope.socket.disconnect()
