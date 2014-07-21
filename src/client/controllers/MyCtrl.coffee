App.controller "MyCtrl", [ "$rootScope", "$scope", "SocketSvc", ($rootScope, $scope, SocketSvc) ->
    $scope.status = "Disconnected"
    $scope.isConnected = false

    $rootScope._socketHandled = false # Флаг, чтобы не повесить обработчики событий socket.io несколько раз

    $scope.uid = "user_x"

    $scope.socket = undefined

    $scope._setConnected = (isConnected, apply) ->
      $scope.status = if isConnected then "Connected" else "Disconnected"
      $scope.isConnected = isConnected
      #if !$scope.$$phase
      if apply
        $scope.$apply()

    $scope.connect = ->
      SocketSvc.connect($scope.uid)
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

    $scope.disconnect = ->
      SocketSvc.disconnect()
]
