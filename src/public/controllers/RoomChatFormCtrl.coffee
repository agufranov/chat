App.controller "roomChatFormCtrl", ($scope) ->
  $scope.text = "Hi all"

  $scope.submit = ->
    $scope.sendMessage($scope.text)
    $scope.text = ""
