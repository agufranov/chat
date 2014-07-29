App.controller "roomChatCtrl", ($rootScope, $scope) ->
  $scope.sendMessage = (body) ->
    msg =
      direction: "out"
      body: body
      from: $rootScope.uid
      to: $scope.$parent.roomChat.name
      id: btoa(Math.random())
    $scope.$parent.sendRoomMessage msg
    $scope.roomChat.messages[msg.id] = msg
