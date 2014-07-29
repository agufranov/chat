App.filter "orderObjectBy", ->
  (items, field, reverse) ->
    filtered = []
    angular.forEach items, (item) ->
      filtered.push item
    filtered.sort (a, b) ->
      if a[field] > b[field] then 1 else -1
    if reverse
      filtered.reverse()
    filtered
