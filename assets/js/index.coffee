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

