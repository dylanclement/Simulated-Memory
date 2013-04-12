class window.GraphCtrl
  constructor: ($scope, $http) ->
    @sys = arbor.ParticleSystem 1000, 800, 0.5  # create the system with sensible repulsion/stiffness/friction
    @sys.renderer = new window.GraphRenderer "#graphCanvas" # our newly created renderer will have its .init() method called shortly by sys...
    # call the rest api endpoint to get the data
    $http.get('/graphData/arbor').success (data) =>
      # get the nodes from the server
      $scope.data = data
      @sys.graft data

    $scope.mousedown = ($event) ->
      console.log $event
      pos = $(this).offset()
      p =
        x: $event.pageX-pos.left
        y: $event.pageY-pos.top

      selected = nearest = dragged = sys.nearest(p)

      if selected.node
        console.log selected, selected.node.name
        @canvas = $('#graphCanvas').get 0
        @ctx = @canvas.getContext "2d"
        @ctx.beginPath null
        @ctx.moveTo selected.screenPoint.x - 10, selected.screenPoint.y - 10
        @ctx.fillStyle = "#500"
        @ctx.fillText selected.node.name, selected.screenPoint.x, selected.screenPoint.y

      return false
