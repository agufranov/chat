App.controller "chatCtrl", ($rootScope, $scope) ->
  $scope.sendMessage = (text) ->
    to = $scope.$parent.chat.uid
    $scope.$parent.sendMessage to, text
    console.log "sendMessage to: #{to} text: #{text}"
    $scope.chat.messages.push { direction: "from", text: text, time: new Date().getTime() }

  #$rootScope.$on "socket:chat message from user", (event, message) ->
    #$scope.chat.messages.push { direction: "to", text: message.text, time: new Date().getTime() }
