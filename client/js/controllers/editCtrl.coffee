window.EditCtrl = ['$scope', '$http', ($scope, $http) ->
    @sys = arbor.ParticleSystem 100, 800, 0.01, true  # create the system with sensible repulsion/stiffness/friction
    @sys.renderer = new window.GraphRenderer "#graphCanvas" # our newly created renderer will have its .init() method called shortly by sys...
    # call the rest api endpoint to get the data
    $http.get('/graphData/arbor').success (data) =>
      # get the nodes from the server
      $scope.data = data
      @sys.graft data

    $scope.click = ($event) =>
      # get the mouse coordinates
      p =
        x: $event.offsetX
        y: $event.offsetY

      # use arbor to find the nearest node
      $scope.selected = @sys.nearest(p)

      # if we found one and the click was close enough
      if $scope.selected.node && $scope.selected.distance < 25
        # If middle mouse then delete the node
        if $event.button == 1
          $scope.deleteNode $event

      return false

    $scope.deleteNode = ($event) =>
      obj = $scope.selected.node.name
      $http.delete("/relationship/#{obj}").success (success) =>
        @sys.pruneNode obj

    delRelationship = (node) =>
      # add the relationship to the graph and to the db
      $http.delete("/relationship/#{Obj}/#{Rel}/#{Sub}").success (success) =>
        @sys.addEdge Obj, Sub, { name: Rel }
]
