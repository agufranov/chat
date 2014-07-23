App.controller "chatCtrl", ($rootScope, $scope) ->
  $scope.sendMessageReceipt = (msg) ->
    return if msg.direction == "out"
    $scope.chat.messages[msg.id].received = true
    $scope.$parent.sendMessageReceipt msg

  $scope.sendMessage = (text) ->
    msg =
      direction: "out"
      text: text
      from: $rootScope.uid
      to: $scope.$parent.chat.uid
      id: btoa(Math.random())
      received: false
    $scope.$parent.sendMessage msg
    $scope.chat.messages[msg.id] = msg

  $scope.sendStartTyping = ->
    console.log "start typing"
    $scope.$parent.sendStartTyping $scope.$parent.chat.uid

  $scope.sendStopTyping = ->
    $scope.$parent.sendStopTyping $scope.$parent.chat.uid
