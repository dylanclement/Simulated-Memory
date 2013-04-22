window.GraphCtrl = ($scope, $http) ->
    @sys = arbor.ParticleSystem 1000, 800, 0.5  # create the system with sensible repulsion/stiffness/friction
    @sys.renderer = new window.GraphRenderer "#graphCanvas" # our newly created renderer will have its .init() method called shortly by sys...
    # call the rest api endpoint to get the data
    $http.get('/graphData/arbor').success (data) =>
      # get the nodes from the server
      $scope.data = data
      @sys.graft data

    $scope.addRel = =>
      Obj = $scope.Obj
      Rel = $scope.Rel
      Sub = $scope.Sub

      # add the relationship to the graph and to the db
      $http.post('/relationship', { Obj, Rel, Sub }).success (success) =>
        @sys.addEdge Obj, Sub, { name: Rel }
