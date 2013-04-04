class DeadSimpleRenderer
  constructor: (canvas) ->
    console.log 'in constructor'
    @canvas = $(canvas).get 0
    @ctx = @canvas.getContext "2d"
    @particleSystem = null

  init: (system) =>
    @particleSystem = system
    @particleSystem.screenSize @canvas.width, @canvas.height
    @particleSystem.screenPadding 80

  redraw: () =>
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height

    @particleSystem.eachEdge (edge, pt1, pt2) =>
      # edge: {source:Node, target:Node, length:#, data:{}}
      # pt1:  {x:#, y:#}  source position in screen coords
      # pt2:  {x:#, y:#}  target position in screen coords

      # draw a line from pt1 to pt2
      @ctx.strokeStyle = "rgba(0,255,255, .333)"
      @ctx.lineWidth = 1 + 4*edge.data.weight
      @ctx.beginPath null
      @ctx.moveTo pt1.x, pt1.y
      @ctx.lineTo pt2.x, pt2.y
      @ctx.stroke null

    @particleSystem.eachNode (node, pt) =>
      # node: {mass:#, p:{x,y}, name:"", data:{}}
      # pt:   {x:#, y:#}  node position in screen coords

      # draw a rectangle centered at pt
      w = 10
      @ctx.fillStyle = "blue"
      @ctx.font = "bold 16px Arial"
      @ctx.fillText node.name, pt.x, pt.y
      @ctx.fillStyle = "black"
      @ctx.fillRect pt.x-w/2, pt.y-w/2, w,w
$ ->
  sys = arbor.ParticleSystem 1000, 800, 0.5  # create the system with sensible repulsion/stiffness/friction
  sys.renderer = new DeadSimpleRenderer "#graphCanvas" # our newly created renderer will have its .init() method called shortly by sys...

  # call the rest api endpoint to get the data
  $.getJSON '/objects', (data) ->
    # get the nodes from the server
    nodes = {}
    data.map (i) ->
      nodes[i.name] = {}

    # get the edges
    $.getJSON '/relationships', (data) ->
      edges = {}
      data.map (i) ->
        edges[i[0]] = {}
        edges[i[0]][i[2]] = { weight : 0.5 }

      console.log edges
      sys.graft {nodes:nodes, edges:edges}
