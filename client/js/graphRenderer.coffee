# Renderer for arbor.js graph visualization engine
class GraphRenderer
  constructor: (canvas) ->
    @canvas = $(canvas).get 0
    @ctx = @canvas.getContext '2d'
    @particleSystem = null

  init: (system) =>
    @particleSystem = system
    @particleSystem.screenSize @canvas.width, @canvas.height
    @particleSystem.screenPadding 80

  redraw: =>
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height
    @ctx.font = 'italic 10px Arial';
    @particleSystem.eachEdge (edge, pt1, pt2) =>
      # edge: {source:Node, target:Node, length:#, data:{}}
      # pt1:  {x:#, y:#}  sourcse position in screen coords
      # pt2:  {x:#, y:#}  target position in screen coords

      # draw a line from pt1 to pt2
      headlen = 10
      angle = Math.atan2 pt2.y - pt1.y,pt2.x - pt1.x
      @ctx.strokeStyle = '#533'
      @ctx.lineWidth = 1
      @ctx.beginPath()
      @ctx.moveTo pt1.x, pt1.y
      @ctx.lineTo pt2.x, pt2.y
      # draw the arrow heads
      midx = (pt1.x + pt2.x) / 2
      midy = (pt1.y + pt2.y) / 2
      @ctx.moveTo midx, midy
      @ctx.lineTo midx-headlen * Math.cos(angle-Math.PI/6),midy-headlen*Math.sin(angle-Math.PI/6)
      @ctx.moveTo midx, midy
      @ctx.lineTo midx-headlen * Math.cos(angle+Math.PI/6),midy-headlen*Math.sin(angle+Math.PI/6)

      @ctx.fillStyle = '#aaa'
      @ctx.fillText edge.data.name, (pt1.x + pt2.x) / 2, (pt1.y + pt2.y) / 2
      @ctx.stroke null

    @particleSystem.eachNode (node, pt) =>
      # node: {mass:#, p:{x,y}, name:'', data:{}}
      # pt:   {x:#, y:#}  node position in screen coords

      # draw a rectangle centered at pt
      w = 5
      @ctx.fillStyle = '#335'
      @ctx.fillText node.name, pt.x + w/2 + 2, pt.y
      @ctx.fillStyle = 'black'
      #@ctx.fillRect pt.x-w/2, pt.y-w/2, w,w
      @ctx.beginPath null
      @ctx.arc pt.x, pt.y, w, 0, 2 * Math.PI, false
      @ctx.strokeStyle = '#003300';
      @ctx.stroke null
      @ctx.fillStyle = '#000'
      # @ctx.fill null

window.GraphRenderer = GraphRenderer
