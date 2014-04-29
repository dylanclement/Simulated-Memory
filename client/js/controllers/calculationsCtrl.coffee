window.CalculationsCtrl = ['$scope', '$http', ($scope, $http) ->
    $scope.cypherText = 'START n=node(*)\n' +
      'RETURN n.name'
    $scope.resultText = ''

    $scope.getAllNodes = ->
      $http.get('/relationship/*')
      .success -> console.log 'Fetched all node data'

    $scope.getAllRelationships = ->
      $http.get('/relationship/*/*/*')
      .success -> console.log 'Fetched all relationship data'

    # add the relationship to the graph and to the db
    $scope.addRel = ->
      $http.post("/relationship/#{$scope.object}/#{$scope.relationship}/#{$scope.subject}")
      .success -> console.log 'Added Relationship', $scope.object, $scope.relationship, $scope.subject

    # clear all objects and relationships from DB
    $scope.clearGraph = ->
      $http.delete('/relationship/*/*/*')
      .success -> console.log 'Cleared Graph'

    # call the rest api endpoint to get the data
    $scope.execCypher = ->
      $http.post('/data/cypher', query: $scope.cypherText)
      .success (data, status) ->
        $scope.resultText = data

    # save data
    $scope.save = -> $http.get('/data/save').success -> console.log 'Saved data'

    # load data
    $scope.load = -> $http.get('/data/load').success -> console.log 'Loaded data'

    # load demo data
    $scope.loadDemo = -> $http.get('/data/load-demo').success -> console.log 'Loaded demo data'
]
