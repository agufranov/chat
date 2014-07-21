App.controller "chatCtrl", ($rootScope, $scope) ->
  $scope.sendMessage = (text) ->
    to = $scope.$parent.chat.uid
    $scope.$parent.sendMessage to, text
    console.log "sendMessage to: #{to} text: #{text}"
