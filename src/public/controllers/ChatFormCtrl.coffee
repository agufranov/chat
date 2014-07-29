App.controller "chatFormCtrl", ($scope) ->
  $scope.text = "Hello"

  $scope.submit = ->
    $scope.sendMessage($scope.text)
    $scope.text = ""
