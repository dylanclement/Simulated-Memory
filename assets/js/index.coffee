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
    @ctx.font = 'italic 10px Arial';
    @particleSystem.eachEdge (edge, pt1, pt2) =>
      # edge: {source:Node, target:Node, length:#, data:{}}
      # pt1:  {x:#, y:#}  source position in screen coords
      # pt2:  {x:#, y:#}  target position in screen coords

      # draw a line from pt1 to pt2
      @ctx.strokeStyle = "#533"
      @ctx.lineWidth = 1 + 4*edge.data.weight
      @ctx.beginPath null
      @ctx.moveTo pt1.x, pt1.y
      @ctx.lineTo pt2.x, pt2.y
      @ctx.fillStyle = "#aaa"
      @ctx.fillText edge.data.name, (pt1.x + pt2.x) / 2, (pt1.y + pt2.y) / 2
      @ctx.stroke null

    @particleSystem.eachNode (node, pt) =>
      # node: {mass:#, p:{x,y}, name:"", data:{}}
      # pt:   {x:#, y:#}  node position in screen coords

      # draw a rectangle centered at pt
      w = 10
      @ctx.fillStyle = "#335"
      @ctx.fillText node.name, pt.x + w/2 + 2, pt.y
      @ctx.fillStyle = "black"
      @ctx.fillRect pt.x-w/2, pt.y-w/2, w,w

$ ->
  sys = arbor.ParticleSystem 1000, 800, 0.5  # create the system with sensible repulsion/stiffness/friction
  sys.renderer = new DeadSimpleRenderer "#graphCanvas" # our newly created renderer will have its .init() method called shortly by sys...

  # call the rest api endpoint to get the data
  $.getJSON '/graphData/arbor', (data) ->
    # get the nodes from the server
    console.log data
    sys.graft data
