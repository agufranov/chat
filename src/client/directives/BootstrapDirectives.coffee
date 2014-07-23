App.directive "panel", ->
  restrict: "EA"
  templateUrl: "templates/bootstrap/Panel.html"
  transclude: true
  scope:
    heading: "@heading"
