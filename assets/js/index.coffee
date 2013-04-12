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
