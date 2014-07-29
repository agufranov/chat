App.controller "chatCtrl", ($rootScope, $scope) ->
  $scope.sendMessageReceipt = (msg) ->
    return if msg.direction == "out"
    return if msg.read == true
    $scope.chat.messages[msg.id].read = true
    $scope.$parent.sendMessageReceipt msg

  $scope.sendMessage = (body) ->
    msg =
      direction: "out"
      body: body
      from: $rootScope.uid
      to: $scope.$parent.chat.uid
      id: btoa(Math.random())
      read: false
    $scope.$parent.sendMessage msg
    $scope.chat.messages[msg.id] = msg

  $scope.typing = false

  $scope.$watch "typing", (newValue, oldValue) ->
    if newValue != oldValue
      $scope.$parent.sendTyping $scope.$parent.chat.uid, newValue

  $scope.sendTyping = (typing) ->
    if typing
      $scope.typing = typing
      clearTimeout $scope.lastTypingTimeout
    else
      $scope.lastTypingTimeout = setTimeout ->
        $scope.$apply ->
          $scope.typing = typing
      , 1000

  $scope.limit = 5
  $scope.offset = 0

  $scope.getHistory = (uid) ->
    $scope.$parent.getHistory uid, $scope.limit, $scope.offset
    $scope.offset += 5
