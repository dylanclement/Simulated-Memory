#module = angular.module("in4mahcy")

GraphCtrl = ($scope, $http) ->
  @sys = arbor.ParticleSystem 1000, 800, 0.5  # create the system with sensible repulsion/stiffness/friction
  @sys.renderer = new window.GraphRenderer "#graphCanvas" # our newly created renderer will have its .init() method called shortly by sys...
  # call the rest api endpoint to get the data
  $http.get('/graphData/arbor').success (data) ->
    # get the nodes from the server
    $scope.data = data
    @sys.graft data

$ ->
  #GraphCtrl.$inject = ["$scope"]
  #module.controller "GraphCtrl", GraphCtrl
  #angular.bootstrap(document, ['in4mahcy'])

  $('#addrel').submit (ev) ->
    obj = $("[name='Obj']").val()
    rel = $("[name='Rel']").val()
    sub = $("[name='Sub']").val()
    sys.addEdge obj, sub, { name: rel }
    $.ajax
      type: 'POST'
      url: '/relationship'
      data:
        Obj: obj
        Rel: rel
        Sub: sub
      success: (success) ->
        console.log success
    return false

  $('#graphCanvas').mousedown (e) ->
    pos = $(this).offset()
    p =
      x: e.pageX-pos.left
      y: e.pageY-pos.top

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

