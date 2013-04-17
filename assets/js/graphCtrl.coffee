window.GraphCtrl = ($scope, $http) ->
    @sys = arbor.ParticleSystem 1000, 800, 0.5  # create the system with sensible repulsion/stiffness/friction
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

      # use arbor to find the nearest node
      $scope.selected = @sys.nearest(p)

      # if we found one and the click was close enough
      if $scope.selected.node && $scope.selected.distance < 25
        console.log $scope.selected, $scope.selected.node.name
        # @canvas = $('#graphCanvas').get 0
        # @ctx = @canvas.getContext "2d"
        # @ctx.beginPath null
        # @ctx.moveTo selected.screenPoint.x - 10, selected.screenPoint.y - 10
        # @ctx.fillStyle = "#500"
        # @ctx.fillText selected.node.name, selected.screenPoint.x, selected.screenPoint.y

      return false

    $scope.addRel = =>
      Obj = $scope.Obj
      Rel = $scope.Rel
      Sub = $scope.Sub

      # add the relationship to the graph and to the db
      $http.post('/relationship', { Obj, Rel, Sub }).success (success) =>
        @sys.addEdge Obj, Sub, { name: Rel }
