window.CalculationsCtrl = ['$scope', '$http', ($scope, $http) ->
    $scope.cypherText = 'START n=node(*)\n' +
      'RETURN n'
    $scope.resultText = ''

    # call the rest api endpoint to get the data
    $scope.execCypher = =>
      # add the relationship to the graph and to the db
      $http.post('/graph/cypher', { query: $scope.cypherText }).success (data, status) =>
        console.log data, status
        $scope.resultText = data
]
